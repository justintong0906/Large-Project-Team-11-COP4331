import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom"
import "./Profile.css"
import pencil from '../../images/pencil.png';

const API_BASE = process.env.REACT_APP_API_BASE;

function ProfileEdit() {

    const navigate = useNavigate();

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
    }, []);


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

    const [imageBase64, setImageBase64] = useState();

    useEffect(() => {
        // Once 'user' data is loaded from the API, set the image state
        if (user && user.profile && user.profile.photo) {
        setImageBase64(user.profile.photo);
        }
    }, [user]);

    const handleImageChange = (e) => {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onloadend = () => {
                setImageBase64(reader.result);
            };
            reader.readAsDataURL(file);
        }
    };

    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");

    const handleSubmit = async () => {
        console.log("got here")
        const photo = imageBase64;
        const name = document.getElementById("name").value;
        const bio = document.getElementById("bio").value;
        const phone = document.getElementById("phone").value;
        const gender = document.getElementById("genderSelect").value;
        const age = document.getElementById("age").value;
        const major = document.getElementById("major").value;
        const yearsOfExperience = document.getElementById("yearsOfExperience").value;

        const genderPreference = document.getElementById("workoutWith").value;
        const days = Array.from(document.querySelectorAll('input[name="workoutDays"]:checked')).map(input => input.value);
        const times = Array.from(document.querySelectorAll('input[name="workoutTime"]:checked')).map(input => input.value);
        let splits = Array.from(document.querySelectorAll('input[name="workoutSplit"]:checked')).map(input => input.value);
        
        // If "any" is selected send all splits (for bitmasking)
        if (splits.includes("any")) {
            splits = ["ppl", "arnold", "brosplit"]; 
        }

            //if missing required * fields
        if(name=='' || gender=='' || genderPreference.length===0 || days.length===0 || times.length===0 || splits.length===0){
            console.log(genderPreference)
            setError("Please fill out empty fields.");
        }
            //send info
        else{
            try {
                const bodyData = {
                    profile: {
                        photo,
                        name,
                        bio,
                        phone,
                        gender,
                        age: age ? Number(age) : undefined,
                        major,
                        yearsOfExperience: yearsOfExperience ? Number(yearsOfExperience) : undefined,
                        genderPreference,
                    },
                    days,   //
                    times,  //
                    splits  //
                };
                console.log("Sending:", bodyData);
                setSuccess("Saving...");

                const response = await fetch(`${API_BASE}/users/me/quiz`, {
                    method: "PUT",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": `Bearer ${localStorage.getItem("token")}`
                    },
                    body: JSON.stringify(bodyData)
                });

                const data = await response.json();
                if (response.ok) {
                    console.log("Edit saved:", data);
                    setError("");
                    setSuccess("Edit saved!");
                    // Redirect to dashboard after a short delay to show success message
                    setTimeout(() => {
                        navigate("/profile");
                    }, 2000);
                } else {
                    setError(data.message || "Failed to save edit");
                }
            } catch (error) {
                console.error("Error saving quiz:", error);
                setSuccess("");
                setError("Failed to save edit.");
            }
        }
    }


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
        <div className="Profile" style={{overflow: "hidden"}}>
            {/* back button */}
            <a className="backButton" style={{backgroundColor:"#f0bdbdc7"}} href="/profile">← Cancel Edit</a>
            {/* edit button */}
            <a className="editButton" style={{backgroundColor:"#bfffbdb7"}} onClick={handleSubmit}>✔︎ Save Changes</a>
            {error && <p class="editError">{error}</p>}
            {success && <p class="editSuccess">{success}</p>}
            {/* LEFT COLUMN */}
            <div style={{ "width": "50%" }}>
                <center>
                    {/* Photo */}
                    <input id="imageInput" type="file" accept="image/*" onChange={handleImageChange} style={{display: 'none'}}/>
                    <div class="images profilePhoto">
                        <img 
                            id="image" 
                            class="profilePhoto" 
                            src={imageBase64} 
                            alt="profile-picture"
                            onClick={() => document.getElementById('imageInput').click()}
                            style={{ cursor: "pointer" }}
                        />
                        <img
                            class="imageOverlay"
                            src = {pencil}
                            alt="profile-picture"
                            onClick={() => document.getElementById('imageInput').click()}
                            style={{ cursor: "pointer" }}
                        />
                    </div>


                    {/* Name */}
                    <br/><label class="editLabel">Name:</label>   <input id="name" class="editInput" placeholder="Name" maxLength="100" defaultValue={p.name}></input><br/>
                    
                    {/* Username */}
                    <p>@{u.username}</p>
                </center>
                
                <div className="userDetails">
                    {/* Age */}
                    <br/><label class="editLabel">Age: </label>     <input id="age" class="editInput eiSmall" placeholder="Age" defaultValue={p.age}></input>
                    
                    {/* Gender */}
                    <label for="genderSelect" class="editLabel" style={{marginLeft: "10px"}}>Gender:</label>
                    <select id="genderSelect" class="editInput eiSmall" defaultValue={p.gender}>
                        <option value="">(Select Gender)</option>
                        <option value="male">Male</option>
                        <option value="female">Female</option>
                        <option value="other">Other</option>
                    </select><br/><br/>

                    {/* Major */}
                    <label class="editLabel">Major:</label>        <input id="major" class="editInput" placeholder="Major" maxLength="100" defaultValue={p.major}></input>
                    <br/><br/>

                    {/* Phone */}
                    <label class="editLabel">
                        Phone Number:
                    </label> 
                    <input id="phone" type="tel" class="editInput" placeholder="Phone Number" defaultValue={p.phone} style={{width: "60%"}} maxLength="20" pattern="[0-9-]*" onInput={(e) => e.target.value = e.target.value.replace(/[^0-9-]/g, '')} /> 
                    <br/>
                </div>
            </div>

            {/* DIVIDER LINE */}
            <div style={{ "width": "2px", "left": "50%", "top": "5%", "bottom": "5%", "backgroundColor": "#D7D7D7" }} />

            {/* RIGHT COLUMN */}
            <div style={{ "width": "50%", paddingLeft: "20px" }}>

                {/* Bio */}
                <p class="editLabel">Bio:</p>          <textarea id="bio" class="editInput" placeholder="Bio" rows="4" maxLength="500" defaultValue={p.bio}></textarea><br/>
                
                {/* a divider line */}
                <div style={{ "height": "2px", "left": "5%", "top": "30%", "right": "5%", "backgroundColor": "#D7D7D7", margin: "10px 0" }} />
                
                <label >Years of Gym Experience:</label> <input id="yearsOfExperience" class="editInput eiSmall" defaultValue={p.yearsOfExperience}></input> Years
                
                {/* Workout splits: render checkboxes, pre-checked based on splits array */}
                <p>Workout Split(s):</p>
                <div class="radioGroupEdit RGEperm">
                    <input type="checkbox" id="ppl" name="workoutSplit" value="ppl" defaultChecked={splits.includes("Push/Pull/Legs")}/>
                    <label for="ppl">Push/Pull/Legs</label>
                    <input type="checkbox" id="arnold" name="workoutSplit" value="arnold" defaultChecked={splits.includes("Arnold")}/>
                    <label for="arnold">Arnold</label>
                    <input type="checkbox" id="brosplit" name="workoutSplit" value="brosplit" defaultChecked={splits.includes("Brosplit")}/>
                    <label for="brosplit">Bro Split</label>
                </div>
                
                <p>Days Available: </p>
                <div class="radioGroupEdit">
                    <input type="checkbox" id="sunday" name="workoutDays" value="sun" defaultChecked={days.includes("Su")}/>
                    <label for="sunday">Su</label>
                    <input type="checkbox" id="monday" name="workoutDays" value="mon" defaultChecked={days.includes("Mo")}/>
                    <label for="monday">Mo</label>
                    <input type="checkbox" id="tuesday" name="workoutDays" value="tue" defaultChecked={days.includes("Tu")}/>
                    <label for="tuesday">Tu</label>
                    <input type="checkbox" id="wednesday" name="workoutDays" value="wed" defaultChecked={days.includes("We")}/>
                    <label for="wednesday">We</label>
                    <input type="checkbox" id="thursday" name="workoutDays" value="thu" defaultChecked={days.includes("Th")}/>
                    <label for="thursday">Th</label>
                    <input type="checkbox" id="friday" name="workoutDays" value="fri" defaultChecked={days.includes("Fr")}/>
                    <label for="friday">Fr</label>
                    <input type="checkbox" id="saturday" name="workoutDays" value="sat" defaultChecked={days.includes("Sa")}/>
                    <label for="saturday">Sa</label>
                </div>
                
                <p>Times Available: </p>
                <div class="radioGroupEdit">
                    <input type="checkbox" id="morning" name="workoutTime" value="morning" defaultChecked={times.includes("Morning")}/>
                    <label for="morning">Morning</label>
                    <input type="checkbox" id="afternoon" name="workoutTime" value="afternoon" defaultChecked={times.includes("Afternoon")}/>
                    <label for="afternoon">Afternoon</label>
                    <input type="checkbox" id="evening" name="workoutTime" value="evening" defaultChecked={times.includes("Evening")}/>
                    <label for="evening">Evening</label>
                </div><br/>

                                    
                {/* Gender Preference */}
                <label class="editLabel">
                    Gender Workout Preference: 
                </label>
                <select id="workoutWith" class="editInput" defaultValue={p.genderPreferences}>
                    <option value="">(Select Gender)</option>
                    <option value="single_gender">Single Gender</option>
                    <option value="no_preference">Any Gender</option>
                </select>
            </div>
        </div>
    );
}

export default ProfileEdit;