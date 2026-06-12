const API_URL = "/notes";

export type Note = {
  id: number;
  title: string;
  content: string;
  createdAt: string;
};

export async function fetchNotes(): Promise<Note[]> {
  const response = await fetch(API_URL);
  if (!response.ok) {
    throw new Error("Impossible de charger les notes");
  }
  return response.json() as Promise<Note[]>;
}

export async function createNote(
  title: string,
  content: string,
): Promise<Note> {
  const response = await fetch(API_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title, content }),
  });
  if (!response.ok) {
    throw new Error("Impossible de créer la note");
  }
  return response.json() as Promise<Note>;
}

export async function deleteNote(id: number): Promise<void> {
  const response = await fetch(`${API_URL}/${id}`, { method: "DELETE" });
  if (!response.ok) {
    throw new Error("Impossible de supprimer la note");
  }
}
