import schedule_img from "../../images/schedule.png"
import preference_img from "../../images/cardio-workout.png"

function Friends() {
    return (
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
    )
}

export default Friends;