import { useState } from "react";
import "./LoginBox.css"

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

    const handleLogin = async () => {
        console.log("Login button clicked");
        const identifier = document.getElementById("IdentifierInput").value;
        const password = document.getElementById("PasswordInput").value;
        
        //call API
        const res = await fetch("http://localhost:5001/api/auth/login", {
            method: "POST",
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


    return(
        <div className="LoginBox">
            <h2 class="lbContent header">Log in</h2>
            <div class="lbContent">
                <input id="IdentifierInput" class="textbox" placeholder="Email/Username" style={{marginBottom:"5px"}}></input>
                <input id="PasswordInput" class="textbox" placeholder="Password" type="password"></input>
                {error && <p style={{color:"red"}}>{error}</p>}
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
    
    const handleSignup = async () => {
        const email = document.getElementById("EmailInput").value;
        const username = document.getElementById("UsernameInput").value;
        const password = document.getElementById("SignupPasswordInput").value;
        const confirmpassword = document.getElementById("SignupConfirmPasswordInput").value;
        
        const res = await fetch("http://localhost:5001/api/auth/signup", {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({username, email, password, confirmpassword})
        });
        const data = await res.json();
        
        if (res.ok) {
            setError("");
            alert(data.message);
        } else {
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
    
    return(
        <div className="LoginBox">
            <h2 class="header">Forgot Password</h2>
            <input id="ForgotEmailInput" class="textbox" placeholder="Email" style={{marginBottom:"10px"}}></input>
            {message && <p>{message}</p>}
            <button class="lbContent LoginButton" onClick={() => setMessage("Instructions has been sent to email, if exists.")}>Send Email</button><br/>
            <a class="lbContent hlink TextButton" style={{fontSize: '15pt'}} onClick={() => setView("login")} >Back to Login</a>
        </div>
    )
}

export {ShowBox, LoginBox, SignupBox}