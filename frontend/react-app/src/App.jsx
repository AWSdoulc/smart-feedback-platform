import { useState } from 'react'

function App() {
  const [userId, setUserId] = useState('')
  const [message, setMessage] = useState('')
  const [response, setResponse] = useState(null)

  const handleSubmit = async (e) => {
    e.preventDefault()
    const payload = {
      userId,
      message,
      timestamp: new Date().toISOString()
    }

    try {
      const res = await fetch("https://bd2twjyav8.execute-api.us-east-1.amazonaws.com/feedback", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify(payload)
      })
      const data = await res.json()
      setResponse("Feedback gesendet!")
      setUserId("")
      setMessage("")
    } catch (err) {
      setResponse("Fehler beim Senden des Feedbacks.")
      console.error(err)
    }
  }

  return (
    <div style={{ padding: "2rem", fontFamily: "sans-serif" }}>
      <h1>Smart Feedback Plattform</h1>
      <form onSubmit={handleSubmit}>
        <div>
          <label>User ID:</label><br />
          <input type="text" value={userId} onChange={(e) => setUserId(e.target.value)} required />
        </div>
        <div>
          <label>Nachricht:</label><br />
          <textarea value={message} onChange={(e) => setMessage(e.target.value)} required />
        </div>
        <button type="submit">Absenden</button>
      </form>
      {response && <p>{response}</p>}
    </div>
  )
}

export default App
