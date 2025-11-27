import LoginSideTab from "./LoginSideTab"
import { ShowBox } from "./LoginBox";
import "./Login.css"
import LoginLogo from "./LoginLogo";
import LoginGraphic from "./LoginGraphic";
import LoginTitle from "./LoginTitle";

import { useNavigate } from "react-router-dom"
import { useEffect } from "react"

function Login() {
    const navigate = useNavigate();
    
    //send user to dashboard if logged in
    useEffect(() => {
        const token = localStorage.getItem("token");
        if (token) {
            navigate("/");
        }
    }, [navigate]);
    
    return(
        <div class="Login" style={{display: "flex"}}>
            <LoginLogo/>
            <LoginTitle/>
            <LoginGraphic/>
            <ShowBox/>
        </div>
    )
}

export default Login;