# MovieDate

## Overview

**MovieDate** is an application designed to help couples find the perfect movie to watch together. By considering the individual preferences of both users, the app suggests movies that are likely to be interesting for both. Users can swipe through recommendations until they agree on a movie to watch.


## Features

- **Personalized Recommendations**: The app generates movie suggestions based on the combined preferences of two users.
- **Swipe-Based Selection**: Users can quickly browse through recommendations by swiping left (reject) or right (interested).
- **Dynamic Matching**: The app refines its suggestions based on previous choices.
- **Matching**: Once a movie is mutually accepted, it is added to a shared watchlist.
- **External Movie Database**: The app fetches movie details (title, genre, rating, summary, etc.) from an external movie recommendation service.

## How It Works

1. Each user inputs their movie preferences (genres, actors, streaming platforms).
2. The app generates a queue of recommended movies.
3. Both users swipe through suggestions independently.
4. When both users swipe right on the same movie, it is added to their shared watchlist and they receive a pop-up.
5. The app continuously learns from their choices to improve future recommendations.

## Technologies Used

- **Frontend**: SwiftUI (for a smooth and responsive user experience)
- **Backend**
  - Firebase Authentication
  - Firebase FireStore Database
  - Movie data provided by The Movie Database (TMDB)
- **Algorithm**: Custom recommendation logic combining user preferences, past likes and matches, and trending movies.


## Future Improvements
- AI-based preference learning for more accurate suggestions
- Social features - get recommendations based on friend couples

## Wireframes

![1](https://github.com/user-attachments/assets/1acece7b-d271-44ca-baf1-75a2323a3795)

![2](https://github.com/user-attachments/assets/0cf45322-d021-473f-a3ba-e028ea2cfb7c)

![3](https://github.com/user-attachments/assets/d0bebf50-c6ef-4aed-bd23-d65d390b7c08)

![4](https://github.com/user-attachments/assets/b51cc3a2-f7d7-436e-a6ac-eed0e7efe9bb)

![5](https://github.com/user-attachments/assets/00b6d992-babe-49db-baa3-b0fb9a6079ac)

![6](https://github.com/user-attachments/assets/73bc9aa6-493e-4142-a03e-75ef110d9f98)

![7](https://github.com/user-attachments/assets/06c7e43e-7ced-43f8-9847-6779a3bf5fe4)

![8](https://github.com/user-attachments/assets/dbaaf262-563e-46e0-9bf2-a2133e864a40)

![9](https://github.com/user-attachments/assets/d0c6c9d0-2f9b-4866-84cc-4b6e5dea9148)

![10](https://github.com/user-attachments/assets/3adf1d74-9d5a-4b9a-924a-2764d7bcaf3d)

![11](https://github.com/user-attachments/assets/8128c193-282c-4690-9e88-06ba295d8804)
