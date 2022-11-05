import streamlit as st

from w3 import W3

st.title("Capstone")

# just display the assets deposited by a user
st.write("Vault")

w3_handler = W3(rpc_url="http://localhost:8545")

address = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
balance = w3_handler.get_balance(address)

st.write(f"Vault balance: {balance}")





