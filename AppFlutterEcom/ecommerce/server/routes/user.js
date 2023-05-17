const express = require("express");
const userRouter = express.Router();
const auth = require("../middlewares/auth");
const Order = require("../models/order");
const { Product } = require("../models/product");
const User = require("../models/user");

userRouter.post("/api/add-to-cart", auth, async (req, res) => {
  try {
    const { id } = req.body;
    const product = await Product.findById(id);
    let user = await User.findById(req.user);

    if (user.cart.length == 0) {
      user.cart.push({ product, quantity: 1 });
    } else {
      let isProductFound = false;
      for (let i = 0; i < user.cart.length; i++) {
        if (user.cart[i].product._id.equals(product._id)) {
          isProductFound = true;
        }
      }

      if (isProductFound) {
        let producttt = user.cart.find((productt) =>
          productt.product._id.equals(product._id)
        );
        producttt.quantity += 1;
      } else {
        user.cart.push({ product, quantity: 1 });
      }
    }
    user = await user.save();
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

userRouter.delete("/api/remove-from-cart/:id", auth, async (req, res) => {
  try {
    const { id } = req.params;
    const product = await Product.findById(id);
    let user = await User.findById(req.user);

    for (let i = 0; i < user.cart.length; i++) {
      if (user.cart[i].product._id.equals(product._id)) {
        if (user.cart[i].quantity == 1) {
          user.cart.splice(i, 1);
        } else {
          user.cart[i].quantity -= 1;
        }
      }
    }
    user = await user.save();
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// save user address
userRouter.post("/api/save-user-address", auth, async (req, res) => {
  try {
    const { address } = req.body;
    let user = await User.findById(req.user);
    user.address = address;
    user = await user.save();
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// order product
userRouter.post("/api/order", auth, async (req, res) => {
  try {
    const { cart, totalPrice, address,paymentTransctionId } = req.body;
    let products = [];

    for (let i = 0; i < cart.length; i++) {
      let product = await Product.findById(cart[i].product._id);
      if (product.quantity >= cart[i].quantity) {
        product.quantity -= cart[i].quantity;
        products.push({ product, quantity: cart[i].quantity });
        await product.save();
      } else {
        return res
          .status(400)
          .json({ msg: `${product.name} is out of stock!` });
      }
    }

    let user = await User.findById(req.user);
    user.cart = [];
    user = await user.save();

    let order = new Order({
      products,
      totalPrice,
      address,
      userId: req.user,
      paymentTransctionId:paymentTransctionId,
      orderedAt: new Date().getTime(),
    });
    order = await order.save();
    res.json(order);

  } catch (e) {
    console.log(e)
    res.status(500).json({ error: e.message });
  }
});


userRouter.get("/api/orders/me", auth, async (req, res) => {
  try {
    const orders = await Order.find();
    res.json(orders);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// /api/products/search/i
userRouter.get("/api/reports", async (req, res) => {
  const {from,to}=req.body
  try {
    const orders = await Order.find({orderedAt:{$gte:Number(new Date(from)),$lt:Number(new Date(to))}});

    res.json(orders);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});


userRouter.post("/api/paymentCallBack", async (req, res) => {
  try {
    
    const data = req.body;

    const order = await Order.findOne({ paymentTransctionId:data.transactionId });
    if (order) {
      order.paymentStatus=req.body.status;
      await order.save();
    //  console.log(order)
      return res
        .status(200)
        .json({ msg: "Order Updated" });
    }

  
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

userRouter.get("/api/paymentCallBack", async (req, res) => {
  try {
    
    const {transactionId} = req.query;
    //console.log(transactionId)

    const order = await Order.findOne({ paymentTransctionId:transactionId });
    if (order) {
      return res
        .status(200)
        .json(order);
    }else{
      return res
      .status(404)
      .json({error:`no order with ${transactionId}`});
    }

  
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// save user address
userRouter.post("/api/order/:id/assignUser", async (req, res) => {
  const id = req.params.id;
  const {assignedUserId} = req.body;
  //console.log(id)
  try {
    let user = await Order.findById(id);
  //  console.log(user)
    user.assignedUserId = assignedUserId;
    user = await user.save();
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

module.exports = userRouter;