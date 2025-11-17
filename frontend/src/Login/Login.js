import LoginSideTab from "./LoginSideTab"
import { ShowBox } from "./LoginBox";
import "./Login.css"
import LoginLogo from "./LoginLogo";
import LoginGraphic from "./LoginGraphic";
import LoginTitle from "./LoginTitle";

function Login() {
    return(
        <div class="Login" style={{display: "flex"}}>
            <LoginLogo/>
            <LoginTitle/>
            <LoginGraphic/>
            <ShowBox/>
            <a href="/quiz">Quiz</a>
        </div>
    )
}

export default Login;