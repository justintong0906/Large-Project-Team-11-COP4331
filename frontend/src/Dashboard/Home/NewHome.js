import { useState, useEffect, useRef } from "react";
import "./NewHome.css"

import xImage from "../../images/x.jpg"
import checkImage from "../../images/check.jpg"

const API_BASE = process.env.REACT_APP_API_BASE;

function NewHome() {
    const [user, setUser] = useState(null);
    const [lastUsername, setLastUsername] = useState("");

    const [error, setError] = useState(null);
    const [reject, setReject] = useState("");
    const [accept, setAccept] = useState("");

    const hasFetchedRef = useRef(false);
    const rejectText = "Rejecting user...";
    const acceptText = "Accepting user...";

    useEffect(() => {
        // If already fetched, stop here.
        if (hasFetchedRef.current){
            return;
        }
        // Mark as fetched
        hasFetchedRef.current = true;
        showRandom();
    }, []);

    const showRandom = () => {
		console.log("Fetching random user...")
		const token = localStorage.getItem("token");

		fetch(`${API_BASE}/users/random-compatible`, {
			method: "GET",
			headers: {
				"Content-Type": "application/json",
				"Authorization": `Bearer ${token}` 
			}
        })
            .then(r => r.json().then(body => ({
                ok: r.ok,
                body
            })))
            .then(({ ok, body }) => {
                if (!ok)
                    throw new Error(body?.message || "Failed to load");
                setUser(body);

                // reroll if they were just shown
                if(body.username == lastUsername){
                    console.log("REROLLING: ", body.username, lastUsername);
                    showRandom();
                    return;
                }
                
                setLastUsername(body.username);
                setAccept("");
                setReject("");


            })
            .catch(e => setError(e.message || "Error"));


	}

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
    	

    const acceptUser = (matchId) => {
		console.log("MATCHING");
        setReject("");
        setAccept(acceptText);

		const token = localStorage.getItem("token");
		if (token && matchId) {
			fetch(`${API_BASE}/users/match/${matchId}`, {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					"Authorization": `Bearer ${token}`
				},
                body: JSON.stringify({}) //the matchId is from the api link parameter, so no need to send any json.
			})
			.then(response => {
				console.log("Match response:", response);
			})
			.catch(error => {
				console.error("Match error:", error);
				console.error("- Selected User Data was: ", user)
			});
		}
        else{
            setError("Error: user/match unidentified.")
        }

        showRandom();
	};

    const rejectUser = () => {
        setReject(rejectText);
        setAccept("");

        showRandom();
    }



    // --- checks and constants -- //

    if (error)
        return <div>Error: {error}</div>;

    if (!user)
        return <div>Loading user...</div>;

    const u = user || {};
    const p = u.profile || {};
    const q = decodeBitmask(u.questionnaireBitmask) || {};

    // 
    const DAYS_ORDER = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
    const TIMES_ORDER = ["Morning", "Afternoon", "Evening"];
    const days = Array.isArray(q.days) ? q.days : [];
    const times = Array.isArray(q.times) ? q.times : [];
    const splits = Array.isArray(q.splits) ? q.splits : [];



    // --- return --- //
    return (
        <div className="Home">
            {/* LEFT COLUMN */}
            <div style={{ "width": "50%" }}>
                <center>
                    {/* Image */}
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
                    {/* Details */}
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

                {/* Workout splits */}
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
                    {/* Render days in order */}
                    {DAYS_ORDER.map(d => (
                        <span key={d} className={days.includes(d) ? "activeBubble" : "inactiveBubble"}>{d}</span>
                    ))}
                </div>

                <p>Times Available: </p>
                <div>
                    {/* Render times in order */}
                    {TIMES_ORDER.map(t => (
                        <span key={t} className={times.includes(t) ? "activeBubble" : "inactiveBubble"}>{t}</span>
                    ))}
                </div>
            </div>

            {/* Bottom-center text */}
            <p className="bottomText">Phone Number: {p.phone}</p>

            {/* Reject and Accept */}
            <img 
                src={xImage}
                alt="Reject"
                onClick={rejectUser}
                style={{ left: "15px" }}
                class="xButton"
            />
            <p
                style = {{ left: "100px", position:"absolute", bottom:"20px", color: "rgb(229, 90, 90)"}}
            >
                {reject}
            </p>

            <img 
                src={checkImage}
                alt="Accept"
                onClick={() => acceptUser(u._id)}
                style={{ right: "15px" }}
                class="checkButton"
            />
            <p
                style = {{ right: "100px", position:"absolute", bottom:"20px", color: "rgb(112, 184, 112)"}}
            >
                {accept}
            </p>
        </div>
    );
}

export default NewHome;