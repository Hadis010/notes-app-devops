import "dotenv/config";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

type Check = {
  label: string;
  run: () => Promise<void>;
};

async function tableExists(tableName: string): Promise<boolean> {
  const result = await prisma.$queryRaw<Array<{ count: bigint }>>`
    SELECT COUNT(*) AS count
    FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name = ${tableName}
  `;

  return Number(result[0]?.count ?? 0) > 0;
}

const checks: Check[] = [
  {
    label: "Connexion MySQL",
    run: async () => {
      await prisma.$queryRaw`SELECT 1`;
    },
  },
  {
    label: "Table Note",
    run: async () => {
      if (!(await tableExists("Note"))) {
        throw new Error("table absente");
      }
    },
  },
  {
    label: "Table _prisma_migrations",
    run: async () => {
      if (!(await tableExists("_prisma_migrations"))) {
        throw new Error("table absente");
      }
    },
  },
];

async function main() {
  console.log("Vérification de l'infrastructure MySQL...\n");

  let hasError = false;

  for (const check of checks) {
    try {
      await check.run();
      console.log(`OK   ${check.label}`);
    } catch (error) {
      hasError = true;
      const message =
        error instanceof Error ? error.message : "erreur inconnue";
      console.error(`ERROR ${check.label} — ${message}`);
    }
  }

  console.log("");

  if (hasError) {
    console.error("Vérification échouée.");
    process.exit(1);
  }

  console.log("Toutes les vérifications ont réussi.");
}

main()
  .catch((error) => {
    console.error("ERROR Vérification inattendue —", error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
