import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import "./Profile.css"

const API_BASE = process.env.REACT_APP_API_BASE;

function Profile() {
  const [user, setUser] = useState(null);
  const [err, setErr] = useState(null);

  useEffect(() => {
    const token = localStorage.getItem("token");
    fetch(`${API_BASE}/users/me`, {
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
  });

  const decodeBitmask = (bitmask) => {
      if (!bitmask && bitmask !== 0) return {};
      
      const DAY_BITS = { "Su": 0, "Mo": 1, "Tu": 2, "We": 3, "Th": 4, "Fr": 5, "Sa": 6 };
      const TIME_BITS = { "Morning": 7, "Afternoon": 8, "Evening": 9 };
      const SPLIT_BITS = { "Arnold": 10, "Push/Pull/Legs": 11, "Brosplit": 12 };
      
      const decodeGroup = (mask, bitMap) => {
          return Object.entries(bitMap)
              .filter(([_, bit]) => mask & (1 << bit))
              .map(([key]) => key);
      };
      
      return {
          days: decodeGroup(bitmask, DAY_BITS),
          times: decodeGroup(bitmask, TIME_BITS),
          splits: decodeGroup(bitmask, SPLIT_BITS)
      };
  };

  if (err) 
    return <div>Error: {err}</div>;

  if (!user) 
    return <div>Loading user...</div>;

  const u = user || {};
  const p = u.profile || {};
  const q = decodeBitmask(u.questionnaireBitmask) || {};

  // added: ordered lists and safe defaults
  const DAYS_ORDER = ["Su","Mo","Tu","We","Th","Fr","Sa"];
  const TIMES_ORDER = ["Morning","Afternoon","Evening"];
  const days = Array.isArray(q.days) ? q.days : [];
  const times = Array.isArray(q.times) ? q.times : [];
  const splits = Array.isArray(q.splits) ? q.splits : [];

  // Simple helper style for the hardcoded "Active" days/times
    return (
        <div className="Profile">
            {/* back button */}
            <a className="backButton" href="/friends">← Back</a>

            {/* LEFT COLUMN */}
            <div style={{ "width": "50%" }}>
                <center>
                    {/* Hardcoded Image Source */}
                    <img 
                        src={p.photo} 
                        className="profilePhoto"
                        alt="Profile Picture"
                    />
                    
                    {/* Name */}
                    <h1>{p.name}</h1>
                    
                    {/* Username */}
                    <p>@{u.username}</p>
                </center>
                
                <div className="userDetails">
                    {/* Hardcoded Details */}
                    <p>{p.age}, {p.gender}</p>
                    <p>{p.major} Major</p>
                </div>
            </div>

            {/* DIVIDER LINE */}
            <div style={{ "width": "2px", "left": "50%", "top": "5%", "bottom": "5%", "backgroundColor": "#D7D7D7" }} />

            {/* RIGHT COLUMN */}
            <div style={{ "width": "50%", paddingLeft: "20px" }}>
                <p>Bio:</p>
                <div className="bioBox">
                    {p.bio}
                </div>
                
                {/* a divider line */}
                <div style={{ "height": "2px", "left": "5%", "top": "30%", "right": "5%", "backgroundColor": "#D7D7D7", margin: "10px 0" }} />
                
                <p>Years of Gym Experience: <span className="permBubble">{p.yearsOfExperience} Years</span></p>
                
                {/* Workout splits: render one permBubble per split present */}
                <p>Workout Split(s):
                    {" "}
                    {splits.length > 0 ? (
                        splits.map(s => <span key={s} className="permBubble">{s}</span>)
                    ) : (
                        <span className="permBubble">N/A</span>
                    )}
                </p>
                
                <p>Days Available: </p>
                <div>
                    {/* Render days in order, active/inactive based on q.days */}
                    {DAYS_ORDER.map(d => (
                        <span key={d} className={days.includes(d) ? "activeBubble" : "inactiveBubble"}>{d}</span>
                    ))}
                </div>
                
                <p>Times Available: </p>
                <div>
                    {/* Render times in order, active/inactive based on q.times */}
                    {TIMES_ORDER.map(t => (
                        <span key={t} className={times.includes(t) ? "activeBubble" : "inactiveBubble"}>{t}</span>
                    ))}
                </div>
            </div>

            {/* Bottom-center text */}
            <p className="bottomText">Phone Number: {p.phone}</p>
        </div>
    );
}

export default Profile;