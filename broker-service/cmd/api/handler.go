package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"net/http"
)

type RequestPayload struct {
	Action string      `json:"action"`
	Auth   AuthPayload `json:"auth,omitempty"`
}

type AuthPayload struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func (app *Config) Broker(w http.ResponseWriter, r *http.Request) {
	payload := jsonResponse{
		Error:   false,
		Message: "Hit the broker",
	}

	_ = app.writeJSON(w, http.StatusOK, payload)
}

func (app *Config) HandleSubmission(w http.ResponseWriter, r *http.Request) {
    var payload RequestPayload

    err := app.readJson(w, r, &payload)
    if err != nil {
        app.errorJSON(w, err)
        return
    }

    switch payload.Action {
    case "auth":
        app.authenticate(w, payload.Auth)
    default:
        app.errorJSON(w, errors.New("unknown action"))
    }
}

func (app *Config) authenticate(w http.ResponseWriter, a AuthPayload) {
    // create some JSON we'll send to auth microservice
    jsonData, _ := json.MarshalIndent(a, "", "\t")

    // call the service
    request, err := http.NewRequest(
        "POST", "http://localhost:8280/authenticate", bytes.NewBuffer(jsonData),
    )
    if err != nil {
        app.errorJSON(w, err)
        return
    }

    client := &http.Client{}
    response, err := client.Do(request)
    if err != nil {
        app.errorJSON(w, err)
        return
    }
    defer response.Body.Close()

    // make sure to receive correct status code

    if response.StatusCode == http.StatusUnauthorized {
        app.errorJSON(w, errors.New("invalid credentials"))
    } else if response.StatusCode != http.StatusAccepted {
        app.errorJSON(w, errors.New("error calling auth service"))
        return
    }

    // create a variable we'll read response.Body into
    var jsonFromService jsonResponse

    // decode json from the auth service
    err = json.NewDecoder(response.Body).Decode(&jsonFromService)
    if err != nil {
        app.errorJSON(w, err)
        return
    }

    if jsonFromService.Error {
        app.errorJSON(w, err, http.StatusUnauthorized)
        return
    }

    var payload jsonResponse
    payload.Error = false
    payload.Message = "Authenticated!"
    payload.Data = jsonFromService.Data

    app.writeJSON(w, http.StatusAccepted, payload)
}
