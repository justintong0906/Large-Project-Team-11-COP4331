import React, { useEffect, useState } from "react";
import { data, useNavigate } from "react-router-dom";
import "./Home.css"
const API_BASE = process.env.REACT_APP_API_BASE;

const mockProfile = {
	name: 'Tom Von Person',
	age: 25,
	gender: "other",
	major: "Undecided",
	bio: "Don't look, this is a fake user.",
	photo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_lvjjRAVDQ-nBDq_4dy1xCyRjjDaHV-Tqcw&s",
	yearsOfExperience: 7,
	genderPreferences: "no_preference"
};


const mockProfile2 = {
	name: 'Bob',
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

    profile: mockProfile,
	
	_id: 1
};

const mockUser2 = {
	username: "SecondaryUser",
    email: "notemail@gmail.com",
    password: "testpassword2",
    emailVerified: true,
	
    emailVerifyTokenHash: "randomGibberishHash2",
    emailVerifyTokenExpiresAt: new Date('2025-12-30T09:00:00Z'),


    questionnaireBitmask: 7032,

    profile: mockProfile2,
	
	_id: 2
};


function Home() {
    const [imageSrc, setImageSrc] = useState("");
	const [initial_load, set_initial_load_flag] = useState(0)
    const [randomUser, setRandomUser] = useState(null);
    const [decodedData, setDecodedData] = useState({ days: [], times: [], splits: [] });
	const [day_states, set_day_states] = useState({
		Sun: 'unset',
        Mon: 'unset',
        Tue: 'unset',
        Wed: 'unset',
		Thu: 'unset',
		Fri: 'unset',
		Sat: 'unset'
    });
	const [time_states, set_time_states] = useState({
		Morning: 'unset',
        Afternoon: 'unset',
        Evening: 'unset'
    });
	
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
			  //decodeBitmask(randomUser.questionnaireBitmask);
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
	
	const sendMatch = (MATCHING_ID) => {
		if (token) {
			fetch(`${API_BASE}/users/match/${MATCHING_ID}`, {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					"Authorization": `Bearer ${token}`
				},
				body: JSON.stringify({})
			})
			.then(response => {
				// Add response handling here
				console.log("Match response:", response);
				if (MATCHING_ID == -999) {
					console.log("sendMatch was provided an ID of -999, meaning randomUser was null.");
				}
			})
			.catch(error => {
				console.error("Match error:", error);
				console.warn("- Selected User Data was: ", randomUser)
			});
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
			checkIfDayIsAvailable('Sun', decoded.days);
			checkIfDayIsAvailable('Mon', decoded.days);
			checkIfDayIsAvailable('Tue', decoded.days);
			checkIfDayIsAvailable('Wed', decoded.days);
			checkIfDayIsAvailable('Thu', decoded.days);
			checkIfDayIsAvailable('Fri', decoded.days);
			checkIfDayIsAvailable('Sat', decoded.days);
			checkIfTimeIsAvailable('Morning', decoded.times);
			checkIfTimeIsAvailable('Afternoon', decoded.times);
			checkIfTimeIsAvailable('Evening', decoded.times);
		}
    }, [randomUser]);
	
	const checkIfDayIsAvailable = (specific_day, available_days) => {
		const word_found = available_days.some(
			word_in_list => word_in_list === specific_day
		);
		
		set_day_states(previous_day_states => ({
			...previous_day_states,
			[specific_day]: word_found ? 'active' : 'inactive'
		}));
		
		return word_found;
	};
	
	const checkIfTimeIsAvailable = (specific_time, available_times) => {
		const word_found = available_times.some(
			word_in_list => word_in_list === specific_time
		);
		
		set_time_states(previous_time_states => ({
			...previous_time_states,
			[specific_time]: word_found ? 'active' : 'inactive'
		}));
		
		return word_found;
	};
	
	
	//hardcode//
	//return (
	//	<div className="tabs-container">
	//		
	//		{/* RIGHT TAB */}
	//		<div 
	//			id="righttab" 
	//			className="tab" 
	//			style={{ position: "absolute", right: "40px", textAlign: "left" }}
	//		>
	//			<div style={{ backgroundColor: "#222", padding: "20px", borderRadius: "10px", color: "white" }}>
	//				<center>
	//					<h2>Biography</h2>
	//					<div className="internal_container">
	//						<p className="text_box">
	//							<span className="fake_tab"></span>
	//							Hi! I'm a Junior majoring in Kinesiology. I usually hit the gym around 5 PM...
	//						</p>
	//					</div>
	//				</center>
	//				<p>Splits: Push/Pull/Legs</p>
	//				<p>Days Available: Mon, Wed, Fri</p>
	//				<p>Experience: 3 years</p>
	//				<button 
	//					className="button-generic" 
	//					style={{ backgroundColor: "#393", right: "20px" }}
	//				>
	//					Accept Match
	//				</button>
	//			</div>
	//		</div>
	//
	//		{/* LEFT TAB */}
	//		<div 
	//			id="lefttab" 
	//			className="tab" 
	//			style={{ position: "absolute", left: "40px", textAlign: "left" }}
	//		>
	//			<div style={{ backgroundColor: "#222", padding: "20px", borderRadius: "10px", color: "white" }}>
	//				<center>
	//					<h2 style={{ color: "#222" }}>.</h2>
	//					<img 
	//						src="https://placehold.co/200" 
	//						className="internal_container" 
	//						alt="profile"
	//						style={{ position: "relative", objectFit: "contain" }} 
	//					/>
	//					<br/><br/>
	//					<h3><b>USERNAME: </b>gym_rat_99</h3>
	//					<h3><b>AGE: </b>22</h3>
	//					<button 
	//						className="button-generic" 
	//						style={{ backgroundColor: "#933", left: "20px" }}
	//					>
	//						Decline Match
	//					</button>
	//				</center>
	//			</div>
	//		</div>
	//
	//	</div>
	//);
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
		<div style={{"display": "flex"}}>
			<div style={{"width":"50%"}}>
				<center>
					<img src={randomUser ? randomUser.profile.photo : ""} class="internal_container" style={{position:"relative", 'object-fit': "contain", "width":"200px", "height":"200px"}}></img>
					<p><b><span style={{'font-size':'30px'}}>{randomUser ? randomUser.profile.name : "Unknown"}</span></b></p>
					<p>{randomUser ? randomUser.username : "Unknown User"}</p>
				</center>
				<div style={{"position":"relative", "left":"32%"}}>
					<p>{randomUser ? randomUser.profile.gender : "Undisclosed"}, {randomUser ? randomUser.profile.age : "Undisclosed"}</p>
					<p>{randomUser ? randomUser.profile.major : "Unknown Major"}</p>
				</div>
				<button 
				onClick={token ? decline_match : switchUserFake}
					className="button-generic"
					style={{'background-color':'#933', 'left':'20px'}}
					disabled={!randomUser} // Disable while loading
				>
					{randomUser ? "Decline Match" : "Loading..."}
				</button>
			</div>
			<div style={{"width":"2px", "left":"49.9%","top":"5%", "bottom":"5%", "background-color":"#D7D7D7"}} />
			<div class="text_box" style={{"width":"50%"}}>
				<p>Bio:</p>
				<p>{randomUser ? (randomUser.profile.bio) : ("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")}</p>
				<div style={{"height":"2px", "left":"5%","top":"30%", "right":"5%", "background-color":"#D7D7D7"}} />
				<p>Years of Gym Experience: <span class="rounded_edges" style={{"background-color":"#B95EFF"}}>{randomUser ? randomUser.profile.yearsOfExperience : 'N/A'}</span></p>
				<p>Workout Split: <span class="rounded_edges" style={{"background-color":"#B95EFF"}}>{decodedData.splits ? decodedData.splits.join('/') : 'N/A'}</span></p>
				<p>Days Available: </p>
				<div>
					<span class={day_states.Sun}>Su</span>
					<span class={day_states.Mon}>Mo</span>
					<span class={day_states.Tue}>Tu</span>
					<span class={day_states.Wed}>We</span>
					<span class={day_states.Thu}>Th</span>
					<span class={day_states.Fri}>Fr</span>
					<span class={day_states.Sat}>Sa</span>
				</div>
				<p>Times Available: </p>
				<div>
					<span class={time_states.Morning}>Morning</span>
					<span class={time_states.Afternoon}>Afternoon</span>
					<span class={time_states.Evening}>Evening</span>
				</div>
				<button 
						onClick={token ? () => accept_match(randomUser ? randomUser._id : -999) : switchUserFake}
						className="button-generic"
						style={{'background-color':'#393', 'right':'20px'}}
						disabled={!randomUser} // Disable while loading
					>
						{randomUser ? "Accept Match" : "Loading..."}
				</button>
			</div>
		</div>
	);

    
}

export default Home;
