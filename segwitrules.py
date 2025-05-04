from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

# CONFIG: Replace with your actual RPC user/pass for the daemon
DAEMON_URL = "http://127.0.0.1:9001"
RPC_AUTH = ("rpcuser", "rpcpassword")

@app.route("/", methods=["POST"])
def proxy():
    incoming = request.get_json()

    # Handle batch of RPC calls
    if isinstance(incoming, list):
        modified_batch = []
        for rpc_req in incoming:
            if rpc_req.get("method") == "getblocktemplate":
                if not rpc_req.get("params"):
                    rpc_req["params"] = [{}]
                if isinstance(rpc_req["params"], list) and isinstance(rpc_req["params"][0], dict):
                    rpc_req["params"][0]["rules"] = ["segwit"]
            modified_batch.append(rpc_req)
        forward = modified_batch

    # Handle single RPC call
    elif isinstance(incoming, dict):
        if incoming.get("method") == "getblocktemplate":
            if not incoming.get("params"):
                incoming["params"] = [{}]
            if isinstance(incoming["params"], list) and isinstance(incoming["params"][0], dict):
                incoming["params"][0]["rules"] = ["segwit"]
        forward = incoming

    else:
        return jsonify({"error": "Invalid request format"}), 400

    # Forward the modified or unmodified RPC to the daemon
    try:
        rpc_res = requests.post(DAEMON_URL, json=forward, auth=RPC_AUTH)
        return jsonify(rpc_res.json())
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8333)
