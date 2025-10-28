import "./TopTab.css"
import LoginTopTab from "./LoginTopTab.js"

function TopTab() {
    
    return(
        <div className="TopTab">
            <div className="NavItem TextButton">Logo</div>
            <div className="NavItem TextButton">Chat</div>
            <div className="NavItem TextButton">Profile</div>
            <div className="NavItem TextButton">Settings</div>
            <LoginTopTab/>
        </div>
    )
}

export default TopTab;