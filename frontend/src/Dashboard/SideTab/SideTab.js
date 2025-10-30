import "./SideTab.css"
import LoginSideTab from "../../Login/LoginSideTab.js"
import logo from "../../images/temp-logo-modified.png"

function SideTab() {
    
    return(
        <div className="SideTab">
            <img className="Logo NavItem TextButton" src={logo} alt="Logo" />
            <div className="NavItem TextButton">Chat</div>
            <div className="NavItem TextButton">Profile</div>
            <div className="NavItem TextButton">Settings</div>
            <a className="NavItem TextButton" href="login" style={{marginTop: 'auto'}}>Log Out</a>
            {/* <LoginSideTab/> */}
        </div>
    )
}

export default SideTab;