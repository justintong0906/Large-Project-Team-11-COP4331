import { useState, useEffect } from "react"
import "./Quiz.css"

import { useNavigate } from "react-router-dom"

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
            if (data.gender) { // if gender exists, they already completed their quiz
                navigate("/");
            }
        })
        .catch(error => {
            console.error("Error fetching quiz status:", error);
        });
    }
  }, [navigate]);


    // changing pfp
    const [imageBase64, setImageBase64] = useState("/default-pfp.png");
    
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
    const handleSubmit = async () => {
        console.log("got here")
        const imageString = imageBase64;
        const firstName = document.getElementById("firstName").value;
        const lastName = document.getElementById("lastName").value;
        const bio = document.getElementById("bio").value;
        const gender = document.getElementById("genderSelect").value;
        const age = document.getElementById("age").value;
        const major = document.getElementById("major").value;
        const yearsOfExperience = document.getElementById("yearsOfExperience").value;

        const genderPreference = Array.from(document.querySelectorAll('input[name="workoutWith"]:checked')).map(input => input.value);
        const days = Array.from(document.querySelectorAll('input[name="workoutDays"]:checked')).map(input => input.value);
        const times = Array.from(document.querySelectorAll('input[name="workoutTime"]:checked')).map(input => input.value);
        let splits = Array.from(document.querySelectorAll('input[name="workoutSplit"]:checked')).map(input => input.value);
        

        // If "any" or "other" is selected send all splits (for bitmasking)
        if (splits.includes("any") || splits.includes("other")) {
            splits = ["ppl", "arnold", "brosplit"];
        }
        const otherSplit = showOtherSplit ? document.getElementById("otherSplit").value : "Any";


            //if missing required * fields
        if(firstName=='' || gender=='' || genderPreference.length===0 || days.length===0 || times.length===0 || splits.length===0){
            setError("Please fill out required fields indicated by *");
        }
            //send info
        else{
            try {
                const response = await fetch(`${API_BASE}/users/me/quiz`, {
                    method: "PUT",
                    headers: {
                        "Content-Type": "application/json",
                        "Authorization": `Bearer ${localStorage.getItem("token")}`
                    },
                    body: JSON.stringify({
                        imageString,
                        firstName,
                        lastName,
                        bio,

                        gender,
                        age,
                        major,
                        yearsOfExperience,

                        genderPreference,
                        days,   //
                        times,  //
                        splits  //
                        //maybe add "otherSplit?"
                    })
                });

                const data = await response.json();
                if (response.ok) {
                    console.log("Quiz saved:", data);
                    setError("");
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
                <p>
                    <img id="image" class="QuizImage" src={imageBase64} alt="profile-picture"></img><br/>
                    <input id="imageInput" type="file" accept="image/*" onChange={handleImageChange} style={{display: 'none'}}/>
                    <button class="Center ButtonPfp" onClick={() => document.getElementById('imageInput').click()}>Change Profile Picture</button>
                </p>

                <h2 class="tbHeader">Primary Information</h2>
                <p class="tbLabel">First Name*</p>   <input id="firstName" class="textbox" placeholder="First Name" maxLength="100"></input><br/>
                <p class="tbLabel">Last Name</p>    <input id="lastName" class="textbox" placeholder="Last Name" maxLength="100"></input><br/>
                <p class="tbLabel">Bio</p>          <textarea id="bio" class="textbox" placeholder="Bio" rows="3" maxLength="500"></textarea><br/>

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
                    <input type="radio" id="ppl" name="workoutSplit" value="pushPullLegs" onChange={handleSplitChange}/>
                    <label for="ppl">Push/Pull/Legs</label>
                    <input type="radio" id="arnold" name="workoutSplit" value="upperLower" onChange={handleSplitChange}/>
                    <label for="arnold">Arnold Split</label>
                    <input type="radio" id="brosplit" name="workoutSplit" value="broSplit" onChange={handleSplitChange}/>
                    <label for="brosplit">Bro Split</label>
                    <input type="radio" id="any" name="workoutSplit" value="any" onChange={handleSplitChange}/>
                    <label for="any">Any</label>
                    <input type="radio" id="other" name="workoutSplit" value="other" onChange={handleSplitChange}/>
                    <label for="other">Other</label>
                </div>
                {showOtherSplit && <input id="otherSplit" class="textbox" placeholder="Specify your workout split" maxLength="100"></input>}             
                
                {error && <p style={{color:"red"}}>{error}</p>}                
                <button class="Center ButtonSubmit" onClick={() => handleSubmit}>Submit</button>
            </div>
        </div>
    )
}

export default Quiz;