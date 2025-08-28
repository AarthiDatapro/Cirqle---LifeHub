require("dotenv").config();
const app = require("./app");
const connectDB = require("./config/db");

const PORT = process.env.PORT || 4000;

(async () => {
  try {
    await connectDB(process.env.MONGODB_URI);
    app.listen(PORT, "0.0.0.0", () => {
      console.log(
        `LifeHub API listening on port ${PORT} (env=${process.env.NODE_ENV})`
      );
      console.log(`Server accessible at: http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error("Failed to start server", err);
    process.exit(1);
  }
})();
