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
        <div className="LoginBox">
            <h2 class="lbContent">Log in</h2>
            <div class="lbContent">
                <input class="textbox" placeholder="Email" style={{marginBottom:"10px"}}></input>
                <input class="textbox" placeholder="Password" type="password"></input>
            </div>
            <div class="lbContent">
                <p style={{fontSize: '18px', marginBottom: "2px"}}>Don't have an account? </p>
                <a 
                    class="lbContent hlink TextButton"
                    style={{fontSize: '15pt'}}
                    onClick={() => setShowLogin(false)}>
                        Register
                </a>
            </div>
            <a class="lbContent" href="#">
                Forgot Password?
            </a>
        </div>
    )
}


function SignupBox({setShowLogin}){
    return(
        <div className="LoginBox">
            <h2 class="lbContent">Sign up</h2>
            <div class = "lbContent">
                <input class="textbox" placeholder="Email" style={{marginBottom:"10px"}}></input><br/>
                <input class="textbox" placeholder="Password " type="password" style={{marginBottom:"10px"}}></input><br/>
                <input class="textbox" placeholder="Confirm Password" type="password"></input>
            </div>

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