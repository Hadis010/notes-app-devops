import { useCallback, useEffect, useState, type FormEvent } from "react";
import {
  createNote,
  deleteNote,
  fetchNotes,
  type Note,
} from "./api/notes.ts";

export default function App() {
  const [notes, setNotes] = useState<Note[]>([]);
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const loadNotes = useCallback(async () => {
    try {
      setError(null);
      const data = await fetchNotes();
      setNotes(data);
    } catch {
      setError("Erreur lors du chargement des notes.");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadNotes();
  }, [loadNotes]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const trimmedTitle = title.trim();
    const trimmedContent = content.trim();
    if (!trimmedTitle || !trimmedContent) {
      setError("Le titre et le contenu sont requis.");
      return;
    }

    try {
      setError(null);
      const note = await createNote(trimmedTitle, trimmedContent);
      setNotes((current) => [note, ...current]);
      setTitle("");
      setContent("");
    } catch {
      setError("Erreur lors de la création de la note.");
    }
  }

  async function handleDelete(id: number) {
    try {
      setError(null);
      await deleteNote(id);
      setNotes((current) => current.filter((note) => note.id !== id));
    } catch {
      setError("Erreur lors de la suppression de la note.");
    }
  }

  return (
    <div className="app">
      <header className="header">
        <h1>Tiny Notes App</h1>
      </header>

      <main className="main">
        {error && <p className="error">{error}</p>}

        <section className="card">
          <h2>Nouvelle note</h2>
          <form className="form" onSubmit={handleSubmit}>
            <label className="field">
              <span>Titre</span>
              <input
                type="text"
                value={title}
                onChange={(event) => setTitle(event.target.value)}
                placeholder="Titre de la note"
              />
            </label>
            <label className="field">
              <span>Contenu</span>
              <textarea
                value={content}
                onChange={(event) => setContent(event.target.value)}
                placeholder="Contenu de la note"
                rows={4}
              />
            </label>
            <button type="submit" className="btn btn-primary">
              Ajouter
            </button>
          </form>
        </section>

        <section className="card">
          <h2>Mes notes</h2>
          {loading ? (
            <p className="muted">Chargement...</p>
          ) : notes.length === 0 ? (
            <p className="muted">Aucune note pour le moment.</p>
          ) : (
            <ul className="notes-list">
              {notes.map((note) => (
                <li key={note.id} className="note-item">
                  <div className="note-content">
                    <h3>{note.title}</h3>
                    <p>{note.content}</p>
                    <time className="note-date">
                      {new Date(note.createdAt).toLocaleString("fr-FR")}
                    </time>
                  </div>
                  <button
                    type="button"
                    className="btn btn-danger"
                    onClick={() => void handleDelete(note.id)}
                  >
                    Supprimer
                  </button>
                </li>
              ))}
            </ul>
          )}
        </section>
      </main>
    </div>
  );
}
