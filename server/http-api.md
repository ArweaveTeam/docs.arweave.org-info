---
description: >-
  An overview of the Arweave HTTP API.
---

# Introduction

The Arweave protocol is based on HTTP, so any existing http clients/libraries can be used to interface with the network, for example Axios or Fetch for JavaScript, Guzzle for PHP, etc.

The default port is **1984**.

Requests and queries can be sent to any Arweave node directly using their IP address, for example [http://159.65.213.43:1984/info](http://159.65.213.43:1984/info).
Hostnames can also be used if configured with DNS, for example [https://arweave.net/info](https://arweave.net/info).

## Sample Request

{% tabs %}
{% tab title="cURL" %}

```bash
curl --request GET \
  --url 'https://arweave.net/info'
```

{% endtab %}
{% tab title="JavaScript (Fetch)" %}

```js
fetch("https://arweave.net/info")
  .then((response) => response.json())
  .then((data) => {
    console.log("Arweave network height is: " + data.height);
  })
  .catch((error) => {
    console.error(error);
  });
```

{% endtab %}

{% tab title="NodeJS" %}

```js
let request = require("request");

let options = {
  method: "GET",
  url: "https://arweave.net/info",
};

request(options, function (error, response, body) {
  if (error) {
    console.error(error);
  }
  console.log("Arweave network height is: " + JSON.parse(body).height);
});
```

{% endtab %}
{% endtabs %}

## Integrations

Arweave specific wrappers and clients are currently in development to simplify common operations and API interactions, there are currently integrations for [Go](https://github.com/everFinance/goar), [PHP](https://github.com/ArweaveTeam/arweave-php), [Scala](https://github.com/toknapp/arweave4s) (which can also be used with Java and C#) and [JavaScript/TypeScript/NodeJS](https://github.com/ArweaveTeam/arweave-js).

## Schema

Common data structures, formats, and processes explained.
