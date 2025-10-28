import "./LoginBox.css"
function LoginBox(){
    return(
        <div className="LoginBox">
            <h3 class="lbContent">Login Box</h3>
            <input class="lbContent textbox" placeholder="Email"></input><br/>
            <input class="lbContent textbox" placeholder="Password" type="password"></input><br/>
            <p class="lbContent" style={{fontSize: '18px', marginBottom: '0px'}}>Don't have an account? </p>
            <a class="lbContent" style={{fontSize: '18px', color:"#80a0d4ff"}} href="#">Register</a>
        </div>
    )
}

export default LoginBox