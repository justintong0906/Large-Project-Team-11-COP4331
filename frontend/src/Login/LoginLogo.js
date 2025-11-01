import logo from "../images/temp-logo-modified.png"
import "./LoginLogo.css"

function LoginLogo(){
    return(
        <a href="/login">
            <img className="LoginLogo" src={logo} alt="Logo"/>
        </a>
    )
}

export default LoginLogo;