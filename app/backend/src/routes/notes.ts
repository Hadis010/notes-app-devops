import { Prisma } from "@prisma/client";
import type { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import { prisma } from "../lib/prisma.js";

type NoteBody = {
  title: string;
  content: string;
};

type IdParams = {
  id: string;
};

function parseId(raw: string): number | null {
  const id = Number(raw);
  if (!Number.isInteger(id) || id < 1) {
    return null;
  }
  return id;
}

function isNoteBody(body: unknown): body is NoteBody {
  if (typeof body !== "object" || body === null) {
    return false;
  }
  const { title, content } = body as Record<string, unknown>;
  return typeof title === "string" && typeof content === "string";
}

function invalidId(reply: FastifyReply) {
  return reply.status(400).send({ error: "Invalid note id" });
}

function notFound(reply: FastifyReply) {
  return reply.status(404).send({ error: "Note not found" });
}

function badRequest(reply: FastifyReply, message: string) {
  return reply.status(400).send({ error: message });
}

function handlePrismaError(
  error: unknown,
  reply: FastifyReply,
  request: FastifyRequest,
): boolean {
  if (
    error instanceof Prisma.PrismaClientKnownRequestError &&
    error.code === "P2025"
  ) {
    void notFound(reply);
    return true;
  }

  request.log.error(error);
  void reply.status(500).send({ error: "Internal server error" });
  return true;
}

export async function notesRoutes(app: FastifyInstance) {
  app.get("/notes", async (request, reply) => {
    try {
      return await prisma.note.findMany({
        orderBy: { createdAt: "desc" },
      });
    } catch (error) {
      handlePrismaError(error, reply, request);
    }
  });

  app.get<{ Params: IdParams }>("/notes/:id", async (request, reply) => {
    const id = parseId(request.params.id);
    if (id === null) {
      return invalidId(reply);
    }

    try {
      const note = await prisma.note.findUnique({ where: { id } });
      if (!note) {
        return notFound(reply);
      }
      return note;
    } catch (error) {
      handlePrismaError(error, reply, request);
    }
  });

  app.post<{ Body: NoteBody }>("/notes", async (request, reply) => {
    if (!isNoteBody(request.body)) {
      return badRequest(reply, "title and content are required");
    }

    const { title, content } = request.body;
    if (!title.trim() || !content.trim()) {
      return badRequest(reply, "title and content cannot be empty");
    }

    try {
      const note = await prisma.note.create({
        data: { title: title.trim(), content: content.trim() },
      });
      return reply.status(201).send(note);
    } catch (error) {
      handlePrismaError(error, reply, request);
    }
  });

  app.put<{ Params: IdParams; Body: NoteBody }>(
    "/notes/:id",
    async (request, reply) => {
      const id = parseId(request.params.id);
      if (id === null) {
        return invalidId(reply);
      }

      if (!isNoteBody(request.body)) {
        return badRequest(reply, "title and content are required");
      }

      const { title, content } = request.body;
      if (!title.trim() || !content.trim()) {
        return badRequest(reply, "title and content cannot be empty");
      }

      try {
        const note = await prisma.note.update({
          where: { id },
          data: { title: title.trim(), content: content.trim() },
        });
        return note;
      } catch (error) {
        handlePrismaError(error, reply, request);
      }
    },
  );

  app.delete<{ Params: IdParams }>("/notes/:id", async (request, reply) => {
    const id = parseId(request.params.id);
    if (id === null) {
      return invalidId(reply);
    }

    try {
      await prisma.note.delete({ where: { id } });
      return reply.status(204).send();
    } catch (error) {
      handlePrismaError(error, reply, request);
    }
  });
}
