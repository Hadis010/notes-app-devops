import "dotenv/config";
import os from "node:os";
import cors from "@fastify/cors";
import Fastify from "fastify";

const app = Fastify({
  logger: true,
});

await app.register(cors);

app.get("/health", async () => {
  return {
    status: "ok",
    hostname: os.hostname(),
  };
});

const port = Number(process.env.PORT) || 3000;
const host = "0.0.0.0";

await app.listen({ port, host });
