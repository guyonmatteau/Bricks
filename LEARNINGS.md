# Learnings acquired during the capstone project

Some very obvious, some less.

- You cannot interact with your MetaMask client using Python, since MetaMask only exists in your browser. Python is not run in your browser so these two run independently from eachother. In order to trigger a MetaMask confirmation you can only use JavaScript.

Contract setup
- We might not even need a "Vault" where users deposit there assets, simply only keeping tracking of the allowances for them is sufficient, and might even be more trustless. To do check with Goncalo.
    - It also removes one layer of complexity and adds a layer of flexibility, since a user does not need to supply funds between his or her wallet and the vault. 
