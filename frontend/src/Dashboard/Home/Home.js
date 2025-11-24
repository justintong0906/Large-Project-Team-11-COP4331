import React, { useEffect, useState } from "react";
import { data, useNavigate } from "react-router-dom";
import "./Home.css"
const API_BASE = process.env.REACT_APP_API_BASE;

const mockProfile = {
	age: 25,
	gender: "other",
	major: "Undecided",
	bio: "Don't look, this is a fake user.",
	photo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_lvjjRAVDQ-nBDq_4dy1xCyRjjDaHV-Tqcw&s",
	yearsOfExperience: 7,
	genderPreferences: "no_preference"
};


const mockProfile2 = {
	age: 37,
	gender: "male",
	major: "Political Science",
	bio: "Lorem nope isum",
	photo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_lvjjRAVDQ-nBDq_4dy1xCyRjjDaHV-Tqcw&s",
	yearsOfExperience: 17,
	genderPreferences: "co_ed"
};




const mockUser = {
	username: "testuser",
    email: "someemail@gmail.com",
    password: "testpassword",
    emailVerified: true,
	
    emailVerifyTokenHash: "randomGibberishHash",
    emailVerifyTokenExpiresAt: new Date('2025-12-31T09:00:00Z'),


    questionnaireBitmask: 7038,

    profile: mockProfile
};

const mockUser2 = {
	username: "SecondaryUser",
    email: "notemail@gmail.com",
    password: "testpassword2",
    emailVerified: true,
	
    emailVerifyTokenHash: "randomGibberishHash2",
    emailVerifyTokenExpiresAt: new Date('2025-12-30T09:00:00Z'),


    questionnaireBitmask: 7032,

    profile: mockProfile2
};


function Home() {
    const [imageSrc, setImageSrc] = useState("");
    const [randomUser, setRandomUser] = useState(null);
    const [decodedData, setDecodedData] = useState({ days: [], times: [], splits: [] });
	const navigate = useNavigate();
	const token = localStorage.getItem("token");
	
	const handleImageUpload = (e) => {
        const file = e.target.files[0]; // file (e) -> binary
        const reader = new FileReader();
        reader.onload = () => { 
            console.log(reader.result); //(after last line) console.log string after loaded
            setImageSrc(reader.result); //  store in ImageSrc
        };
        reader.readAsDataURL(file); // binary -> string
    };
	
	const [error, setError] = useState("");	
	
	
	const decodeBitmask = (bitmask) => {
        if (!bitmask && bitmask !== 0) return {};
        
        const DAY_BITS = { Sun: 0, Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6 };
        const TIME_BITS = { Morning: 7, Afternoon: 8, Evening: 9 };
        const SPLIT_BITS = { Arnold: 10, Ppl: 11, Brosplit: 12 };
        
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
	
	const RandomUserComponent = () => {
		const fakeToken = 'fake-jwt-token-' + Math.random().toString(36).substr(2, 9);
		console.log(token);
		console.log(fakeToken);
		if (token) {
		  fetch(`${API_BASE}/users/random-compatible`, {
			method: "GET",
			headers: {
			  "Content-Type": "application/json",
			  "Authorization": `Bearer ${token}`
			}
		  })
		  .then(response => {
			if (!response.ok) {
			  //throw new Error("Network response was not ok");
			  console.warn("NO CONNECTION MADE: Using Mock User");
			  setRandomUser(mockUser);
			  return;
			}
			return response.json();
		  })
		  .then(data => {
			setRandomUser(data);
		  })
		  .catch(err => {
			console.error("Error fetching random user:", err);
			setError(err.message);
		  });
		} else {
			if (fakeToken) {
				setRandomUser(mockUser);
				return;
			} else {
				navigate("/login"); // Redirect to login if no token is found
			}
		}
	};
	
	const sendMatch = () => {
		if (token) {
			fetch(`${API_BASE}/users/send_match`, {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					"Authorization": `Bearer ${token}`
				},
				body: JSON.stringify({ data: randomUser.username })
			})
		};
	};
	
	const switchUserFake = () => {
		console.log("SWITCHING");
		setRandomUser(prevUser => (prevUser === mockUser ? mockUser2 : mockUser));
	};
	
	const accept_match = () => {
		console.log("MATCHING");
		// Call match endpoint function as well here
		sendMatch();
		RandomUserComponent();
	};
	
	const decline_match = () => {
		console.log("DECLINING MATCH");
		RandomUserComponent();
	};
		
	useEffect(() => {
        RandomUserComponent();
    }, []);
	
	useEffect(() => {
        if (randomUser) {
            const decoded = decodeBitmask(randomUser.questionnaireBitmask);
            setDecodedData(decoded);
        }
    }, [randomUser]);

	
	//hardcode//
	return (
		<div className="tabs-container">
			
			{/* RIGHT TAB */}
			<div 
				id="righttab" 
				className="tab" 
				style={{ position: "absolute", right: "40px", textAlign: "left" }}
			>
				<div style={{ backgroundColor: "#336", padding: "20px", borderRadius: "10px", color: "white" }}>
					<center>
						<h2>Biography</h2>
						<div className="internal_container">
							<p className="text_box">
								<span className="fake_tab"></span>
								Hi! I'm a Junior majoring in Kinesiology. I usually hit the gym around 5 PM...
							</p>
						</div>
					</center>
					<p>Splits: Push/Pull/Legs</p>
					<p>Days Available: Mon, Wed, Fri</p>
					<p>Experience: 3 years</p>
					<button 
						className="button-generic" 
						style={{ backgroundColor: "#393", right: "20px" }}
					>
						Accept Match
					</button>
				</div>
			</div>

			{/* LEFT TAB */}
			<div 
				id="lefttab" 
				className="tab" 
				style={{ position: "absolute", left: "40px", textAlign: "left" }}
			>
				<div style={{ backgroundColor: "#633", padding: "20px", borderRadius: "10px", color: "white" }}>
					<center>
						<h2 style={{ color: "#333" }}>.</h2>
						<img 
							src="https://placehold.co/200" 
							className="internal_container" 
							alt="profile"
							style={{ position: "relative", objectFit: "contain" }} 
						/>
						<br/><br/>
						<h3><b>USERNAME: </b>gym_rat_99</h3>
						<h3><b>AGE: </b>22</h3>
						<button 
							className="button-generic" 
							style={{ backgroundColor: "#933", left: "20px" }}
						>
							Decline Match
						</button>
					</center>
				</div>
			</div>

		</div>
	);
	////
	
	if (error) {
		return <div>Error: {error}</div>;
	}

	if (!randomUser) {
		if (token) {
			return <div>Error: Can't find a compatible user</div>
		}
		else {
			return <div>Loading...</div>;
		}
	}
	

	return(
		<div className="tabs-container">
			<div id="righttab" style={{position:"absolute", right:"40px", 'text-align':"left"}} className="tab">
				<div style={{"background-color":'#336'}}>
					<center>
						<h2>Biography</h2>
						<div class="internal_container">
							<p class="text_box"><span class="fake_tab" />{randomUser ? (randomUser.profile.bio) : ("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")}</p>
						</div>
					</center>
					<p>Splits        : {decodedData.splits ? decodedData.splits.join(', ') : 'N/A'}</p>
					<p>Days Available: {decodedData.days ? decodedData.days.join(', ') : 'N/A'}</p>
					<p>Experience    : {randomUser ? randomUser.profile.yearsOfExperience : 'N/A'} years</p>
					<button 
						onClick={token ? accept_match : switchUserFake}
						className="button-generic"
						style={{'background-color':'#393', 'right':'20px'}}
						disabled={!randomUser} // Disable while loading
					>
						{randomUser ? "Accept Match" : "Loading..."}
					</button>
				</div>
			</div>
			<div id="lefttab" style={{position:"absolute", left:"40px", 'text-align':"left"}} className="tab">
				<div style={{"background-color":'#633'}}>
					<center>
						<h2 style={{color:'#333'}}>.</h2>
						<img src={randomUser ? randomUser.profile.photo : ""} class="internal_container" style={{position:"relative", 'object-fit': "contain"}}></img>
						<br />
						{ /*
						<div style={{bottom:"5vh", position:"absolute"}}>
							<input 
								type="file" accept="image/*" // this is the default "choose file" button and prompts to file explorer
								onChange={handleImageUpload}
							/>
						</div>
						*/ }
						< br />
						<h3><b>USERNAME: </b>{randomUser ? (randomUser.username) : ("Loading...") }</h3>
						<h3><b>AGE: </b>{randomUser ? (randomUser.profile.age) : (99)}</h3>
						
						{/* Use switchUserFake for testing locally */}
						<button 
						onClick={token ? decline_match : switchUserFake}
							className="button-generic"
							style={{'background-color':'#933', 'left':'20px'}}
							disabled={!randomUser} // Disable while loading
						>
							{randomUser ? "Decline Match" : "Loading..."}
						</button>
					</center>
					
				</ div>
			</div>
		</div>
		
	);

    
}

export default Home;
