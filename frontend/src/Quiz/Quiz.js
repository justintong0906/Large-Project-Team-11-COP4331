import { useState, useEffect } from "react"
import "./Quiz.css"

import { useNavigate } from "react-router-dom"
import { DEFAULT_PFP } from "./default-pfp-b64";

const API_BASE = process.env.REACT_APP_API_BASE;

function Quiz(){

    //send user back to login if not logged in
    const navigate = useNavigate();
    useEffect(() => {
        const token = localStorage.getItem("token");
        if (!token) {
            navigate("/login");
        }
    }, [navigate]);


    //send user to dashboard if already did quiz
    useEffect(() => {
        const token = localStorage.getItem("token");
        if (token) {
            fetch(`${API_BASE}/users/me`, {
                method: "GET",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": `Bearer ${token}`
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.profile.gender) { // if gender exists, they already completed their quiz
                    navigate("/");
                }
            })
            .catch(error => {
                console.error("Error fetching quiz status:", error);
            });
        }
    }, [navigate]);


    // changing pfp
    const [imageBase64, setImageBase64] = useState(DEFAULT_PFP);
    
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


    // different split
    const [showOtherSplit, setShowOtherSplit] = useState(false);
    const handleSplitChange = (e) => {
        setShowOtherSplit(e.target.value === "other");
    };


    //error for empty
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");

    const handleLogout = () => {
        localStorage.removeItem("token");
        navigate("/login");
    };
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

        const genderPreference = Array.from(document.querySelectorAll('input[name="workoutWith"]:checked')).map(input => input.value);
        const days = Array.from(document.querySelectorAll('input[name="workoutDays"]:checked')).map(input => input.value);
        const times = Array.from(document.querySelectorAll('input[name="workoutTime"]:checked')).map(input => input.value);
        let splits = Array.from(document.querySelectorAll('input[name="workoutSplit"]:checked')).map(input => input.value);
        

        // If "any" is selected send all splits (for bitmasking)
        if (splits.includes("any")) {
            splits = ["ppl", "arnold", "brosplit"]; 
        }

            //if missing required * fields
        if(name=='' || gender=='' || genderPreference.length===0 || days.length===0 || times.length===0 || splits.length===0){
            setError("Please fill out required fields indicated by *");
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
                    console.log("Quiz saved:", data);
                    setError("");
                    setSuccess("Quiz saved successfully!");
                    // Redirect to dashboard after a short delay to show success message
                    setTimeout(() => {
                        navigate("/");
                    }, 2000);
                } else {
                    setError(data.message || "Failed to save quiz");
                }
            } catch (error) {
                console.error("Error saving quiz:", error);
                setError("Failed to save quiz. Please try again.");
            }
        }
    }

    return(
        <div class="Quiz">
            <h1 class="Title">User Quiz</h1>
            <div class="CenterQuiz">
                <a className="LogoutButton" onClick={handleLogout}>Logout</a>
                <p>
                    <img id="image" class="QuizImage" src={imageBase64} alt="profile-picture"></img><br/>
                    <input id="imageInput" type="file" accept="image/*" onChange={handleImageChange} style={{display: 'none'}}/>
                    <button class="Center ButtonPfp" onClick={() => document.getElementById('imageInput').click()}>Change Profile Picture</button>
                </p>

                <h2 class="tbHeader">Primary Information</h2>
                <p class="tbLabel">Name*</p>   <input id="name" class="textbox" placeholder="Name" maxLength="100"></input><br/>
                <p class="tbLabel">Bio</p>          <textarea id="bio" class="textbox" placeholder="Bio" rows="3" maxLength="500"></textarea><br/>
                <p class="tbLabel">Phone Number</p>   <input id="phone" type="tel" class="textbox" placeholder="Phone Number" maxLength="15" pattern="[0-9]*" onInput={(e) => e.target.value = e.target.value.replace(/[^0-9]/g, '')}></input><br/>

                <h2 class="tbHeader">Additional Information</h2>
                <label for="genderSelect" class="tbLabel">Gender*</label>
                <select id="genderSelect" class="textbox">
                    <option value="">(Select Gender)</option>
                    <option value="male">Male</option>
                    <option value="female">Female</option>
                    <option value="other">Other</option>
                </select><br/>
                <p class="tbLabel">Age</p>          <input id="age" type="number" class="textbox" placeholder="Age" min="0"></input><br/>
                <p class="tbLabel">Major</p>        <input id="major" class="textbox" placeholder="Major" maxLength="100"></input><br/>
                <p class="tbLabel">Years of Gym Experience</p>  <input id="yearsOfExperience" type="number" class="textbox" placeholder="Years of Gym Experience" min="0"></input><br/>

                <h2 class="tbHeader">Preferences</h2>
                <p class="tbLabel">1. What gender would you work out with?*</p>
                <div class="radioGroup">
                    <input type="radio" id="singleGender" name="workoutWith" value="single_gender"/>
                    <label for="singleGender">Single Gender</label>
                    <input type="radio" id="anyGender" name="workoutWith" value="no_preference"/>
                    <label for="anyGender">Any Gender</label>
                </div>

                <p class="tbLabel">2. What days can you work out?*</p>
                <div class="radioGroup">
                    <input type="checkbox" id="sunday" name="workoutDays" value="sun"/>
                    <label for="sunday">Sunday</label>
                    <input type="checkbox" id="monday" name="workoutDays" value="mon"/>
                    <label for="monday">Monday</label>
                    <input type="checkbox" id="tuesday" name="workoutDays" value="tue"/>
                    <label for="tuesday">Tuesday</label>
                    <input type="checkbox" id="wednesday" name="workoutDays" value="wed"/>
                    <label for="wednesday">Wednesday</label>
                    <input type="checkbox" id="thursday" name="workoutDays" value="thu"/>
                    <label for="thursday">Thursday</label>
                    <input type="checkbox" id="friday" name="workoutDays" value="fri"/>
                    <label for="friday">Friday</label>
                    <input type="checkbox" id="saturday" name="workoutDays" value="sat"/>
                    <label for="saturday">Saturday</label>
                </div>

                <p class="tbLabel">3. What time of day can you work out?*</p>
                <div class="radioGroup">
                    <input type="checkbox" id="morning" name="workoutTime" value="morning"/>
                    <label for="morning">Morning</label>
                    <input type="checkbox" id="afternoon" name="workoutTime" value="afternoon"/>
                    <label for="afternoon">Afternoon</label>
                    <input type="checkbox" id="evening" name="workoutTime" value="evening"/>
                    <label for="evening">Evening</label>
                </div>

                <p class="tbLabel">4. What is your preferred workout split?*</p>
                <div class="radioGroup">
                    <input type="radio" id="ppl" name="workoutSplit" value="ppl" onChange={handleSplitChange}/>
                    <label for="ppl">Push/Pull/Legs</label>
                    <input type="radio" id="arnold" name="workoutSplit" value="arnold" onChange={handleSplitChange}/>
                    <label for="arnold">Arnold Split</label>
                    <input type="radio" id="brosplit" name="workoutSplit" value="brosplit" onChange={handleSplitChange}/>
                    <label for="brosplit">Bro Split</label>
                    <input type="radio" id="any" name="workoutSplit" value="any" onChange={handleSplitChange}/>
                    <label for="any">Any</label>
                </div>
                
                {error && <p style={{color:"red", textAlign:"center"}}>{error}</p>}       
                {success && <p style={{color:"green", textAlign:"center"}}>{success}</p>}                         
                <button class="Center ButtonSubmit" onClick={handleSubmit}>Submit</button>
            </div>
        </div>
    )
}

export default Quiz;