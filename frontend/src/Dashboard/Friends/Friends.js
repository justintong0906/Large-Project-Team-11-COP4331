import "./Friends.css"
import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
const API_BASE = process.env.REACT_APP_API_BASE;

// function Friends() {
//     return (
//         <div className="FriendsTab Grid">
//             <div class="GridItem">
//                 <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_lvjjRAVDQ-nBDq_4dy1xCyRjjDaHV-Tqcw&s" class="Image"/>
//                 <h2 class="Name">John Doe</h2>
//             </div>
//             <div class="GridItem">Item 2</div>
//             <div class="GridItem">Item 3</div>
//             <div class="GridItem">Item 4</div>
//             <div class="GridItem">Item 5</div>
//             <div class="GridItem">Item 6</div>
//         </div>			
//     )
// }


function Friends() {
    //get current profile friends
    const [friends, setFriends] = useState([]);
    useEffect(() => {
        const fetchFriends = async () => {
            const token = localStorage.getItem("token");
            const res = await fetch(`${API_BASE}/users/me`, {
                headers: {"Authorization": `Bearer ${token}`}
            });
            const data = await res.json();
            if (res.ok) setFriends(data.friends);
        };
        fetchFriends();
    }, []);

    return (
        <div className="FriendsTab Grid">
            {friends.length === 0 ? (
                <div>No friends found</div>
            ) : (
                friends.map(friend => (
                <Link
                    to={`/friends/${friend._id}`}
                    key={friend._id}
                    className="GridItem LinkReset"
                >
                    <img src={friend.profile?.photo} className="Image" alt={`${friend.username} profile picture`} />
                    <h3 className="Name">{friend.profile?.name}</h3>
                    <h4 className="Username">{friend.username}</h4>
                </Link>
                ))
            )}
        </div>            
    )
}


export default Friends;