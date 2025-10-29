import { useState } from "react";
import "../../Dashboard/SideTab.css"
import {LoginBox, ShowBox} from "./LoginBox.js"

function LoginSideTab() {    
    let isSignedIn = true; // Change to true to test

    return(
        <div class="NavItem TextButton">
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

            {showLoginDiv && (<ShowBox/>)}
        </div>
    );
}

function Logout(){
    return(
        <a href="/homepage.html" className="NavItem TextButton" style={{ textDecoration: 'none'}}>Log out</a>
    )
}

export default LoginSideTab;