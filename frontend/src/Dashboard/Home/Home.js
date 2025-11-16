import { useState } from "react";
import "./Home.css"
const API_BASE = process.env.REACT_APP_API_BASE;


function Home() {
    const [imageSrc, setImageSrc] = useState("");
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
	{ /*
	const handleLogin = async () => {
        console.log("Login button clicked");
        const identifier = document.getElementById("IdentifierInput").value;
        const password = document.getElementById("PasswordInput").value;
        
        //call API
        console.log(`${API_BASE}/random-compatible`);
        const res = await fetch(`${API_BASE}/random-compatible`, {
            method: "GET",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({identifier, password})
        });
        const data = await res.json();

        //response
        if (res.ok) {
            localStorage.setItem("token", data.token);
            window.location.href = "/";
        } else {
            setError(data.message);
        }
    };
	*/}

	return(
		<div>
			<div id="righttab" style={{position:"absolute", right:"40px", 'text-align':"left"}}>
				<p>Hey</p>
				<div class="container" style={{"background-color":'#336'}}>
					<center>
						<h2>Biography</h2>
						<div class="internal_container">
						<p class="text_box"><span class="fake_tab" />Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. </p>
						</div>
					</center>
					<p>Splits        : Arnolds</p>
					<p>Days Available: Mon, Wedn, Fri</p>
					<p>Experience    : 5 years</p>
				</div>
			</div>
			<div id="lefttab" style={{position:"absolute", left:"40px", 'text-align':"left"}}>
				<p>Hey</p>
				<div class="container">
					<center>
						<h2 style={{color:'#333'}}>.</h2>
						<div class="internal_container">
							<img src={imageSrc} class="internal_container" style={{position:"relative", 'object-fit': "contain"}}></img>
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
						</div>
					</center>
				</ div>
			</div>
			<center>
				<p style={{'text-align':"center"}}>Mid</p>
			</center>
		</div>
		
	);

    
}

export default Home;
