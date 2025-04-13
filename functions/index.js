const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const razorpay = require("razorpay");

admin.initializeApp();

const razorpayClient = new razorpay({
  key_id: "rzp_test_1DP5mmOlF5G5ag", // Replace with actual test key
  key_secret: "dummy_secret",  // Replace with actual secret key
});

exports.createOrder = functions.https.onRequest(async (req, res) => {
  try {
    if (req.method !== "POST") {
      return res.status(405).send("Method Not Allowed");
    }

    const { amount, receipt } = req.body;

    if (!amount || !receipt) {
      return res.status(400).send("Missing amount or receipt");
    }

    const options = {
      amount: amount * 100, // Razorpay accepts amount in paise
      currency: "INR",
      receipt: receipt || "receipt_001", // (Optional)
    };

    const order = await razorpayClient.orders.create(options);

    return res.status(200).json(order);
  } catch (error) {
    console.error("Error creating order:", error);
    return res.status(500).send("Internal Server Error");
  }
});
