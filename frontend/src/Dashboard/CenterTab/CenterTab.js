import "./CenterTab.css"
import schedule_img from "../../images/schedule.png"
import preference_img from "../../images/cardio-workout.png"

function CenterTab({ getVisible }) {
    
    return(
		<div className="CenterTab">
			{getVisible === 0 && 
				<div className="HomeTab">
				<center>
				<h2>This is your home page!</h2>
				<h6>Kinda empty isn't it...?</h6>
				</center>
				</div>
			}
			{getVisible === 1 && 
				<div className="FriendsTab">
					<table>
						<colgroup>
							<col style={{width:"20%"}} />
							<col style={{width:"15%"}} />
							<col style={{width:"15%"}} />
							<col style={{width:"35%"}} />
							<col style={{width:"17%"}} />
						</colgroup>
						<tr>
							<th>Name</th>
							<th>
								<p><img src={schedule_img} alt="Schedule"/> Matches</p>
							</th>
							<th>
								<p><img src={preference_img} alt="Preference"/> Matches</p>
							</th>
							<th>Profile</th>
							<th>Ⓧ Remove Friend</th>
						</tr>
						<tr>
							<td>Bob TestPerson</td>
							<td>2</td>
							<td>13</td>
							<td>This is Bob's Profile</td>
							<td><button className="RemoveBTN">Remove</button></td>
						</tr>
						<tr>
							<td>Alice NotExist</td>
							<td>3</td>
							<td>17</td>
							<td>This is Alice's Profile</td>
							<td><button className="RemoveBTN">Remove</button></td>
						</tr>
						<tr>
							<td>Kyle SirNobody</td>
							<td>2</td>
							<td>14</td>
							<td>This is Kyle's Profile</td>
							<td><button className="RemoveBTN">Remove</button></td>
						</tr>
						<tr>
							<td>Sam Nothing</td>
							<td>5</td>
							<td>11</td>
							<td>This is Sam's Profile</td>
							<td><button className="RemoveBTN">Remove</button></td>
						</tr>
					</table>				
				</div>
			}
			{getVisible === 2 && 
				<div className="ProfileTab">
				</div>
			}
			{getVisible === 3 && 
				<div className="SettingsTab">
					<h4>UAC</h4>
					<button>Change Username</button>
					<button>Change Password</button>
					<button>Change Email</button>
					<h4>Data</h4>
					<button>Retake Preference Quiz</button>
					<button>Purge Swipes</button>
				</div>
			}
		</div>
    )
}

export default CenterTab;