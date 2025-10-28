import { useState } from "react";
import "./LoginBox.css"

function ShowBox() {
    const [showLogin, setShowLogin] = useState(true);
    return(
        <>
            {showLogin ? <LoginBox setShowLogin={setShowLogin}/> : <SignupBox setShowLogin={setShowLogin}/>}
        </>
    )
}

function LoginBox({setShowLogin}){
    return(
        <div className="LoginBox" style={{height: "300px"}}>
            <h3 class="lbContent">Log in</h3><br/>
            <input class="lbContent textbox" placeholder="Email"></input><br/>
            <input class="lbContent textbox" placeholder="Password" type="password"></input><br/>
            <p class="lbContent" style={{fontSize: '18px', marginBottom: "0px"}}>Don't have an account? </p>
            <a 
                class="lbContent hlink TextButton"
                style={{fontSize: '15pt'}}
                onClick={() => setShowLogin(false)}>
                    Register
            </a>
        </div>
    )
}


function SignupBox({setShowLogin}){
    return(
        <div className="LoginBox" style={{height: "350px"}}>
            <h3 class="lbContent">Sign up</h3><br/>
            <input class="lbContent textbox" placeholder="Email"></input><br/>
            <input class="lbContent textbox" placeholder="Password" type="password"></input><br/>
            <input class="lbContent textbox" placeholder="Confirm Password" type="password"></input><br/>
            <p class="lbContent" style={{fontSize: '18px', marginBottom: "0px"}}>Already have an account? </p>
            <a 
                class="lbContent hlink TextButton"
                style={{fontSize: '15pt'}}
                onClick={() => setShowLogin(true)}>
                    Log in
            </a>
        </div>
    )
}

export {ShowBox, LoginBox, SignupBox}