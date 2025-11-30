import { useState } from "react";
import "./LoginBox.css"
const API_BASE = process.env.REACT_APP_API_BASE;

function ShowBox() {
    const [view, setView] = useState("login");
    
    switch(view) {
        case "login":
            return <LoginBox setView={setView}/>;
        case "signup":
            return <SignupBox setView={setView}/>;
        case "forgot":
            return <ForgotPassword setView={setView}/>;
        default:
            return <LoginBox setView={setView}/>;
    }
}

function LoginBox({setView}){
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");

    const handleLogin = async () => {
        console.log("Login button clicked");
        setSuccess("Logging in...");
        const identifier = document.getElementById("IdentifierInput").value;
        const password = document.getElementById("PasswordInput").value;
        
        //call API
        console.log(`${API_BASE}/auth/login`);
        const res = await fetch(`${API_BASE}/auth/login`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({identifier, password})
        });
        const data = await res.json();

        //response
        if (res.ok) {
            setError("");
            setSuccess("Login successful!");
            localStorage.setItem("token", data.token);
            setTimeout(() => window.location.href = "/", 2000);
        } else {
            setSuccess("");
            setError(data.message);
        }
    };


    return(
        <div className="LoginBox">
            <h2 class="lbContent header">Log in</h2>
            <div class="lbContent">
                <input id="IdentifierInput" class="textbox" placeholder="Email/Username" style={{marginBottom:"5px"}}></input>
                <input id="PasswordInput" class="textbox" placeholder="Password" type="password"></input>
                {error && <p style={{color:"red"}}>{error}</p>}
                {success && <p style={{color:"green"}}>{success}</p>}
            </div>
            <button class="lbContent LoginButton" onClick={handleLogin}>Log in</button>
            <div class="lbContent">
                <p style={{fontSize: '18px', marginBottom: "2px"}}>Don't have an account? </p>
                <a 
                    class="lbContent hlink TextButton"
                    style={{fontSize: '15pt'}}
                    onClick={() => setView("signup")}>
                        Register
                </a>
            </div>
            <a class="lbContent ForgotButton" onClick={() => setView("forgot")}>
                Forgot Password?
            </a>
        </div>
    )
}


function SignupBox({setView}){
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");
    
    const handleSignup = async () => {
        setSuccess("Signing Up...");
        const email = document.getElementById("EmailInput").value;
        const username = document.getElementById("UsernameInput").value;
        const password = document.getElementById("SignupPasswordInput").value;
        const confirmpassword = document.getElementById("SignupConfirmPasswordInput").value;
        
        const res = await fetch(`${API_BASE}/auth/signup`, {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({username, email, password, confirmpassword})
        });
        const data = await res.json();
        
        if (res.ok) {
            console.log("Signup successful!");
            console.log(data.message)
            setError("");
            setSuccess(data.message);
            if (data.token) {
                localStorage.setItem("token", data.token);
            }
        } else {
            setSuccess("");
            setError(data.message);
        }
    };

    return(
        <div className="LoginBox">
            <h2 class="header lbContent">Sign up</h2>
            <div class = "lbContent">
                <input id="EmailInput" class="textbox" placeholder="Email" style={{marginBottom:"5px"}}></input><br/>
                <input id="UsernameInput" class="textbox" placeholder="Username" style={{marginBottom:"5px"}}></input><br/>
                <input id="SignupPasswordInput" class="textbox" placeholder="Password " type="password" style={{marginBottom:"5px"}}></input><br/>
                <input id="SignupConfirmPasswordInput" class="textbox" placeholder="Confirm Password" type="password"></input>
                {error && <p style={{color:"red"}}>{error}</p>}
                {success && <p style={{color:"green"}}>{success}</p>}
            </div>
            <button class="lbContent LoginButton" onClick={handleSignup}>Sign up</button>

            <p class="lbContent" style={{fontSize: '18px', marginBottom: "0px"}}>Already have an account? </p>
            <a 
                class="lbContent hlink TextButton"
                style={{fontSize: '15pt'}}
                onClick={() => setView("login")}>
                    Log in
            </a>
        </div>
    )
}

function ForgotPassword({setView}){
    const [message, setMessage] = useState("");
    const [error, setError] = useState("");

    const handleForgot = async () => {
        setMessage("Sending email...");
        const email = document.getElementById("ForgotEmailInput").value;
        const res = await fetch(`${API_BASE}/auth/forgot-password`, {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({email})
        });
        const data = await res.json();

        if (res.ok) {
            setMessage(data.message);
            setError("");
        } else {
            setError(data.message);
            setMessage("");
        }
    };
    
    return(
        <div className="LoginBox">
            <h2 class="header">Forgot Password</h2>
            <input id="ForgotEmailInput" class="textbox" placeholder="Email" style={{marginBottom:"10px"}}></input>
            {error && <p style={{color:"red"}}>{error}</p>}
            {message && <p style={{color:"green"}}>{message}</p>}

            <button class="lbContent LoginButton" onClick={handleForgot}>Send Email</button><br/>
            <a class="lbContent hlink TextButton" style={{fontSize: '15pt'}} onClick={() => setView("login")} >Back to Login</a>
        </div>
    )
}

export {ShowBox, LoginBox, SignupBox}