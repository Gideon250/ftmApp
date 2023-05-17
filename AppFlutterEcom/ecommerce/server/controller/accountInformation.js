var Paypack = require("paypack");

Paypack.config({ client_id: "da918e58-8ffb-11ed-b0d2-dead986dd4f7", client_secret: "6cace3a8bb78dfee1d3219d50acedb18da39a3ee5e6b4b0d3255bfef95601890afd80709" });

Paypack.me()
  .then((res) => {
    console.log(res.data);
  })
  .catch((err) => {
    console.log(err);
  });