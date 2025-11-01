

function LoginTitle() {
    return (
        <a href="/login"
        className="LoginTitle" style={
            {
                margin:"15px", 
                marginLeft: "30px",
                textDecoration: 'none', 
                color: 'white',
                fontFamily: 'Verdana, sans-serif',
                fontWeight: '600',
            }
            }>
            <h1 style={{margin: 22}}>Gym Buddy Matcher for RWC</h1>
        </a>
    )
}


export default LoginTitle;