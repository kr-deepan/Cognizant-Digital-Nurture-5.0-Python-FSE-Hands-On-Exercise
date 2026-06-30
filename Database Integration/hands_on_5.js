// Create Collection

db.createCollection("feedback");

// Insert Sample Documents

db.feedback.insertMany([
{
    student_id: 1,
    course_code: "CS101",
    semester: "2022-ODD",
    rating: 5,
    comments: "Excellent teaching.",
    tags: ["challenging", "well-structured", "good-examples"],
    submitted_at: new Date("2022-11-30"),
    attachments: [
        { filename: "notes.pdf", size_kb: 240 }
    ]
},
{
    student_id: 2,
    course_code: "CS101",
    semester: "2022-ODD",
    rating: 4,
    comments: "Very useful.",
    tags: ["challenging", "practical"],
    submitted_at: new Date("2022-11-28"),
    attachments: [
        { filename: "assignment.pdf", size_kb: 180 }
    ]
},
{
    student_id: 3,
    course_code: "CS101",
    semester: "2021-EVEN",
    rating: 2,
    comments: "Difficult course.",
    tags: ["challenging"],
    submitted_at: new Date("2021-11-20")
},
{
    student_id: 4,
    course_code: "CS102",
    semester: "2022-ODD",
    rating: 5,
    comments: "Loved the labs.",
    tags: ["interactive", "good-examples"],
    submitted_at: new Date("2022-12-01"),
    attachments: [
        { filename: "lab.pdf", size_kb: 100 }
    ]
},
{
    student_id: 5,
    course_code: "CS102",
    semester: "2022-EVEN",
    rating: 3,
    comments: "Average experience.",
    tags: ["average"],
    submitted_at: new Date("2022-05-15"),
    attachments: [
        { filename: "report.pdf", size_kb: 120 }
    ]
},
{
    student_id: 6,
    course_code: "CS103",
    semester: "2022-ODD",
    rating: 1,
    comments: "Needs improvement.",
    tags: ["poor"],
    submitted_at: new Date("2022-11-15"),
    attachments: [
        { filename: "feedback.pdf", size_kb: 90 }
    ]
},
{
    student_id: 7,
    course_code: "CS103",
    semester: "2022-EVEN",
    rating: 4,
    comments: "Good overall.",
    tags: ["good"],
    submitted_at: new Date("2022-06-10"),
    attachments: [
        { filename: "review.pdf", size_kb: 110 }
    ]
},
{
    student_id: 8,
    course_code: "CS104",
    semester: "2022-ODD",
    rating: 5,
    comments: "Fantastic course.",
    tags: ["excellent", "good-examples"],
    submitted_at: new Date("2022-12-05"),
    attachments: [
        { filename: "slides.pdf", size_kb: 300 }
    ]
},
{
    student_id: 9,
    course_code: "CS105",
    semester: "2022-EVEN",
    rating: 2,
    comments: "Too theoretical.",
    tags: ["challenging"],
    submitted_at: new Date("2022-04-01"),
    attachments: [
        { filename: "notes.pdf", size_kb: 200 }
    ]
},
{
    student_id: 10,
    course_code: "CS105",
    semester: "2022-ODD",
    rating: 5,
    comments: "Excellent material.",
    tags: ["challenging", "excellent"],
    submitted_at: new Date("2022-12-10"),
    attachments: [
        { filename: "summary.pdf", size_kb: 140 }
    ]
}
]);

// Verification

db.feedback.countDocuments();

// Expected Result: 10

// CRUD Operations
// Find feedback with rating 5

db.feedback.find({
    rating: 5
});

// Find feedback for CS101 containing "challenging"

db.feedback.find({
    course_code: "CS101",
    tags: "challenging"
});

// Projection Example

db.feedback.find(
    {},
    {
        student_id: 1,
        course_code: 1,
        rating: 1,
        _id: 0
    }
);

// Update documents with rating less than 3

db.feedback.updateMany(
    {
        rating: { $lt: 3 }
    },
    {
        $set: {
            needs_review: true
        }
    }
);

// Add new tag to reviewed documents

db.feedback.updateMany(
    {
        needs_review: true
    },
    {
        $push: {
            tags: "reviewed"
        }
    }
);

// Delete older semester data

db.feedback.deleteMany({
    semester: "2021-EVEN"
});

// Aggregation Pipeline

// Average Rating by Course

db.feedback.aggregate([
{
    $match: {
        semester: "2022-ODD"
    }
},
{
    $group: {
        _id: "$course_code",
        avg_rating: {
            $avg: "$rating"
        },
        feedback_count: {
            $sum: 1
        }
    }
},
{
    $sort: {
        avg_rating: -1
    }
}
]);

// Formatted Aggregation Output

db.feedback.aggregate([
{
    $match: {
        semester: "2022-ODD"
    }
},
{
    $group: {
        _id: "$course_code",
        avg_rating: {
            $avg: "$rating"
        },
        feedback_count: {
            $sum: 1
        }
    }
},
{
    $project: {
        _id: 0,
        course_code: "$_id",
        average_rating: {
            $round: ["$avg_rating", 1]
        },
        feedback_count: 1
    }
},
{
    $sort: {
        average_rating: -1
    }
}
]);

// Tag Frequency Analysis

db.feedback.aggregate([
{
    $unwind: "$tags"
},
{
    $group: {
        _id: "$tags",
        count: {
            $sum: 1
        }
    }
},
{
    $sort: {
        count: -1
    }
}
]);

// Indexing

// Create Index

db.feedback.createIndex({
    course_code: 1
});

// Verify Index Usage

db.feedback.find({
    course_code: "CS101"
}).explain("executionStats");

// Expected:
// Query planner should use IXSCAN
// instead of COLLSCAN when possible.

// Documentation

// Document Structure:
// - Scalar Fields
// - Arrays (tags)
// - Embedded Documents (attachments)

// CRUD Operations Covered:
// - Insert
// - Find
// - Update
// - Delete

// Aggregation Stages Used:
// - $match
// - $group
// - $project
// - $sort
// - $unwind

// Indexing:
// course_code field indexed for faster lookups