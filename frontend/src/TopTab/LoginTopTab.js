import { useState } from "react";
import "./TopTab.css"
import LoginBox from "./LoginBox.js"

function LoginTopTab() {    
    let isSignedIn = true; // Change to true to test

    return(
        <div style={{marginLeft: 'auto'}}>
            {isSignedIn ? <Login /> : <Logout/>}
        </div>
    )
}

function Login(){
    const [showLoginDiv, setShowLoginDiv] = useState(false);
    return (
        <div style={{ position: "relative", display: "inline-block" }}>
            <div
                onClick={(e) => {
                    e.preventDefault();
                    setShowLoginDiv(!showLoginDiv);
                }}
                className="NavItem TextButton"
                style={{ marginLeft: "auto"}}
            >
                Log in
            </div>

            {showLoginDiv && (<LoginBox/>)}
        </div>
    );
}

function Logout(){
    return(
        <a href="/homepage.html" className="NavItem TextButton" style={{marginLeft: 'auto', textDecoration: 'none'}}>Log out</a>
    )
}

export default LoginTopTab;