---
description: Here is a step-by-step guide for generating an Arweave cold wallet
---

# Generating a Cold Wallet

The following procedure allows you to generate an extremely secure Arweave cold wallet. Using this procedure, your keys will never be exposed to an internet-connected computer before you intend to use your tokens, giving you exceptionally strong guarantees about the security of your AR.

{% hint style="info" %}
This procedure may seem long but we have broken each of its steps down into granular chunks that should be simple to follow
{% endhint %}

### Cold Wallet generation with Arweave.app

1. Open up [https://arweave.app](https://arweave.app) in your browser tab.
2. Once loaded, disconnect your computer from the internet
3. Click the \[ + ] button in the bottom left&#x20;
   ![arweave.app add wallet button in welcome screen](<../.gitbook/assets/cold_wallet_arweave_app_plus.png>)
4. Click the big "Create new wallet" button in the screen that pops up.
   ![arweave.app create wallet screen](<../.gitbook/assets/cold_wallet_arweave_app_create_btn.png>)
5. Write down your passphrase on a piece of paper.
6. When the wallet generation step completes, click the "Click to proceed" button.
   ![arweave.app proceed btn](<../.gitbook/assets/cold_wallet_arweave_app_proceed_btn.png>)
7. Identify your newly created wallet on the next screen and click the "Download" button to download the key file.
   ![arweave.app download wallet](<../.gitbook/assets/cold_wallet_arweave_app_download_wallet.png>)
8. Make copies of this file on multiple offline storage mediums (for example, USB sticks or prints of the file to physical paper). **Store these copies securely**
9.  Click the "Delete" button to remove your newly created wallet from the browser.
    ![arweave.app delete wallet](<../.gitbook/assets/cold_wallet_arweave_app_delete_wallet.png>)
10. Reconnect to the internet

### Cold Wallet generation with the ArDrive CLI (Advanced)

{% hint style="warning" %}
**This process is for more advanced users. If you have not used a CLI before, it is recommended to follow the guides above!**
{% endhint %}

1. You'll need to have [Node.js](https://nodejs.org/) and [npm](https://docs.npmjs.com/cli/v9/) installed for the ArDrive CLI to work.
2. Open up your OS' default terminal and install the [ArDrive CLI](https://www.npmjs.com/package/ardrive-cli) with the following command:
```sh
npm install -g ardrive-cli
```
3. Disconnect your device from the internet.
4. Generate a seedphrase with the following command, then write it down on a piece of paper.
```sh
ardrive generate-seedphrase
```
5. Copy the generated seedphrase and paste it between the quotes in the following command. Run the command to generate a keyfile.
```sh
ardrive generate-wallet -s "PASTE_GENERATED_SEEDPHRASE_HERE" > ./wallet.json
```
6. You'll be able to find you keyfile name `wallet.json` in the directory where you ran the CLI. You should copy it to an offline storage medium and delete the file from your device.
7. You can now reconnect your device to the internet.

{% hint style="success" %}
**Congratulations for completing the steps! Your AR tokens will now be stored safely and securely for months and years to come**
{% endhint %}

Had problems? Don’t worry, drop us a line at [team@arweave.org](mailto:team@arweave.org) and we'd be happy to help.

If you'd like to make transactions from your cold wallet the ArDrive command line tool has a nice writeup for how to [securely send a transaction from a cold wallet](https://github.com/ardriveapp/ardrive-cli#cold-tx).