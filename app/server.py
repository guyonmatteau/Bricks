import os
import flask
from flask import Flask, render_template, request, send_from_directory

from app.chain import Chain

app = Flask(__name__, static_url_path="/static")
app.jinja_env.add_extension("jinja2.ext.do")


@app.route("/")
@app.route("/index")
def landing():
    return render_template("index.html")


@app.route("/connect")
def connect():
    address = request.args.get("address")
    chain_id = request.args.get("chain")

    print(f"Current address: {address}")
    print(f"Current chain_id: {chain_id}")

    chain = Chain(chain_id=chain_id)
    balance = chain.get_balance(address)

    print(f"Balance of {address} on chain {chain}: {balance}")
    return render_template("index.html", chain=chain_id, address=address, balance=balance)
