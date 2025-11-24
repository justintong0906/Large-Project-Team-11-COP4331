import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";

const API_BASE = process.env.REACT_APP_API_BASE;

function FriendProfile() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState(null);

  useEffect(() => {
    if (!id) {
        return;
    }
    const token = localStorage.getItem("token");
    fetch(`${API_BASE}/users/${id}`, {
      headers: { Authorization: `Bearer ${token}` },
    })
      .then(r => r.json().then(body => ({ 
        ok: r.ok, 
        body 
      })))
      .then(({ ok, body }) => {
        if (!ok) 
            throw new Error(body?.message || "Failed to load");
        setUser(body);
      })
      .catch(e => setErr(e.message || "Error"))
      .finally(() => setLoading(false));
  }, [id]);

  if (loading) 
    return <div>Loading profile…</div>;

  if (err) 
    return <div>Error: {err}</div>;

  if (!user) 
    return <div>No user found</div>;

  const p = user.profile || {};

  return (
    <div className="ProfilePage">
      <button onClick={() => navigate(-1)}>Back</button>
      <img src={p.photo} alt={`${p.name} avatar`} />
      <h1>{p.name || user.username}</h1>
      <h2>@{user.username}</h2>
      {p.age != null && <div>Age: {p.age}</div>}
      {p.major && <div>Major: {p.major}</div>}
      {p.bio && <p>{p.bio}</p>}
      {p.phone && <div>Phone: {p.phone}</div>}
      {/* Optionally decode and show questionnaire preferences */}
      {typeof user.questionnaireBitmask === "number" && (
        <div>
          <strong>Preferences</strong>
          {/* decode helper output here */}
        </div>
      )}
    </div>
  );
}

export default FriendProfile;