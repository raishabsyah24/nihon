import { PrismaClient, Role } from "@prisma/client";

const prisma = new PrismaClient();

type Args = {
  firebaseUid?: string;
  email?: string;
  displayName?: string;
};

async function main() {
  const args = parseArgs(process.argv.slice(2));

  if (!args.firebaseUid && !args.email) {
    throw new Error(
      "Use --firebaseUid=<uid> or --email=<email> to select a user.",
    );
  }

  const existing = await findExistingUser(args);

  if (existing) {
    const user = await prisma.user.update({
      where: { id: existing.id },
      data: {
        role: Role.ADMIN,
        email: args.email ?? existing.email,
        displayName: args.displayName ?? existing.displayName,
      },
    });
    console.log(
      `Promoted admin: ${user.id} (${user.email ?? user.firebaseUid})`,
    );
    return;
  }

  if (!args.firebaseUid) {
    throw new Error(
      "User was not found. Creating a new admin requires --firebaseUid=<uid>.",
    );
  }

  const user = await prisma.user.create({
    data: {
      firebaseUid: args.firebaseUid,
      email: args.email,
      displayName: args.displayName ?? "Nihon e Ikitai Admin",
      role: Role.ADMIN,
    },
  });

  console.log(`Created admin: ${user.id} (${user.email ?? user.firebaseUid})`);
}

function parseArgs(argv: string[]): Args {
  const args: Args = {};

  for (let index = 0; index < argv.length; index += 1) {
    const item = argv[index];
    if (!item.startsWith("--")) {
      continue;
    }

    const [rawKey, inlineValue] = item.slice(2).split("=", 2);
    const key = rawKey as keyof Args;
    const value = inlineValue ?? argv[index + 1];

    if (inlineValue === undefined) {
      index += 1;
    }

    if (
      key in args ||
      ["firebaseUid", "email", "displayName"].includes(key)
    ) {
      args[key] = value;
    }
  }

  return args;
}

async function findExistingUser(args: Args) {
  if (args.firebaseUid) {
    return prisma.user.findUnique({ where: { firebaseUid: args.firebaseUid } });
  }

  if (args.email) {
    return prisma.user.findFirst({ where: { email: args.email } });
  }

  return null;
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
