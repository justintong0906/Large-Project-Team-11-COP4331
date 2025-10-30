import "./SideTab.css"
import LoginSideTab from "../../Login/LoginSideTab.js"
import logo from "../../images/temp-logo-modified.png"

function SideTab() {
    
    return(
        <div className="SideTab">
            <a href="/">
                <img className="Logo NavItem TextButton" src={logo} alt="Logo" />
            </a>
            <a className="NavItem TextButton" href="/">Home</a>
            <a className="NavItem TextButton">Friends</a>
            <a className="NavItem TextButton">Profile</a>
            <a className="NavItem TextButton">Settings</a>
            <a className="NavItem TextButton" href="/login" style={{marginTop: 'auto'}}>Log Out</a>
            {/* <LoginSideTab/> */}
        </div>
    )
}

export default SideTab;