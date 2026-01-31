let cooldownInterval = null;

document.getElementById('repairButton').addEventListener('click', function() {
    // Clear any previous message
    document.getElementById('message').textContent = '';
    if (cooldownInterval) {
        clearInterval(cooldownInterval);
        cooldownInterval = null;
    }
    
    // Send the repair call
    fetch(`https://${GetParentResourceName()}/callRepair`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' || event.key === 'Backspace') {
        if (cooldownInterval) {
            clearInterval(cooldownInterval);
            cooldownInterval = null;
        }
        fetch(`https://${GetParentResourceName()}/closeNUI`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    }
});

window.addEventListener('message', function(event) {
    const data = event.data;
    const container = document.querySelector('.container');
    const messageDiv = document.getElementById('message');
    
    if (data.type === 'show') {
        container.style.display = 'block';
        messageDiv.textContent = '';  // Clear message when showing
        if (cooldownInterval) {
            clearInterval(cooldownInterval);
            cooldownInterval = null;
        }
    } else if (data.type === 'hide') {
        container.style.display = 'none';
        if (cooldownInterval) {
            clearInterval(cooldownInterval);
            cooldownInterval = null;
        }
    } else if (data.type === 'cooldown') {
        let remainingMs = data.remainingMs;
        
        function updateMessage() {
            if (remainingMs > 0) {
                let minutes = Math.floor(remainingMs / 60000);
                let seconds = Math.floor((remainingMs % 60000) / 1000);
                let timeString = minutes + ":" + (seconds < 10 ? "0" + seconds : seconds);
                messageDiv.textContent = "Please wait " + timeString;
            } else {
                messageDiv.textContent = '';
                clearInterval(cooldownInterval);
                cooldownInterval = null;
            }
        }
        
        updateMessage();  // Initial update
        
        cooldownInterval = setInterval(() => {
            remainingMs -= 1000;
            updateMessage();
        }, 1000);
    }
});