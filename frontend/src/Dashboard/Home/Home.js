import { useState } from "react";

function Home() {
    const [imageSrc, setImageSrc] = useState("");
    const handleImageUpload = (e) => {
        const file = e.target.files[0]; // file (e) -> binary
        const reader = new FileReader();
        reader.onload = () => { 
            console.log(reader.result); //(after last line) console.log string after loaded
            setImageSrc(reader.result); //  store in ImageSrc
        };
        reader.readAsDataURL(file); // binary -> string
    };

    return(
        <div className="HomeTab">
            <center>
                <h2>This is your home page!</h2>
                <h6>Kinda empty isn't it...?</h6>
                <input 
                    type="file" accept="image/*" // this is the default "choose file" button and prompts to file explorer
                    onChange={handleImageUpload} 
                />
                <img src={imageSrc} style={{width: "100px"}}></img>
            </center>
        </div>
    )
}

export default Home;
