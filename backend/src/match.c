#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define NUM_USERS 30
#define TOP_MATCHES 10
#define DAYS 7
#define TIMES 4

// Split types
const char *splits[] = {
    "Push/Pull/Legs",
    "Chest-Back/Arms/Legs",
    "Upper/Lower Body"
};

// Struct representing a user
typedef struct {
    int id;
    int years_experience;
    int schedule[DAYS][TIMES]; // 1 = available, 0 = not
    int split_type;             // 0, 1, or 2
    double match_score;
} User;

// Function prototypes
User generate_random_user(int id);
double calculate_match_score(User a, User b);
void print_user(User u);
int compare_scores(const void *a, const void *b);

int main() {
    srand(time(NULL));

    // Generate current app user
    User current_user = generate_random_user(0);
    printf("=== Current User ===\n");
    print_user(current_user);

    // Generate 30 random users
    User users[NUM_USERS];
    for (int i = 0; i < NUM_USERS; i++) {
        users[i] = generate_random_user(i + 1);
        users[i].match_score = calculate_match_score(current_user, users[i]);
    }

    // Sort by match score descending
    qsort(users, NUM_USERS, sizeof(User), compare_scores);

    // Display top 10 matches
    printf("\n=== Top %d Matches ===\n", TOP_MATCHES);
    for (int i = 0; i < TOP_MATCHES; i++) {
        printf("\nRank #%d | User %d | Score: %.2f\n", i + 1, users[i].id, users[i].match_score);
        print_user(users[i]);
    }

    return 0;
}

// Generate a random user
User generate_random_user(int id) {
    User u;
    u.id = id;
    u.years_experience = rand() % 11; // 0–10 years
    u.split_type = rand() % 3;

    // Random availability (50% chance each slot)
    for (int d = 0; d < DAYS; d++)
        for (int t = 0; t < TIMES; t++)
            u.schedule[d][t] = rand() % 2;

    u.match_score = 0.0;
    return u;
}

// Calculate compatibility score
double calculate_match_score(User a, User b) {
    double score = 0.0;

    // Experience similarity (max 30)
    int diff = abs(a.years_experience - b.years_experience);
    score += (30.0 - (diff * 3.0)); // -3 points per year difference
    if (score < 0) score = 0;

    // Schedule overlap (3 pts per matching slot)
    int overlap = 0;
    for (int d = 0; d < DAYS; d++)
        for (int t = 0; t < TIMES; t++)
            if (a.schedule[d][t] && b.schedule[d][t])
                overlap++;
    score += overlap * 3.0;

    // Split match bonus (60 points)
    if (a.split_type == b.split_type)
        score += 60.0;

    return score;
}

// Compare function for qsort (descending order)
int compare_scores(const void *a, const void *b) {
    double scoreA = ((User *)a)->match_score;
    double scoreB = ((User *)b)->match_score;
    return (scoreB > scoreA) - (scoreB < scoreA);
}

// Print user details
void print_user(User u) {
    printf("User %d | Exp: %d years | Split: %s\n", 
           u.id, u.years_experience, splits[u.split_type]);
    printf("Schedule:\n");
    const char *times[TIMES] = {"Morning", "Mid", "Afternoon", "Night"};
    for (int d = 0; d < DAYS; d++) {
        printf("  Day %d: ", d + 1);
        for (int t = 0; t < TIMES; t++)
            if (u.schedule[d][t])
                printf("%s ", times[t]);
        printf("\n");
    }
}

