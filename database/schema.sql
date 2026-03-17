CREATE TABLE "users" (
  "id" integer PRIMARY KEY,
  "username" varchar(50) NOT NULL UNIQUE,
  "created_at" timestamp NOT NULL DEFAULT now(),
  "updated_at" timestamp NOT NULL DEFAULT now()
);

CREATE TABLE "follows" (
  "following_user_id" integer NOT NULL,
  "followed_user_id" integer NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT now(),
  PRIMARY KEY ("following_user_id", "followed_user_id")
);

CREATE TABLE "posts" (
  "id" integer PRIMARY KEY,
  "title" varchar(255),
  "body" text,
  "media" json,
  "latitude" decimal(9,6),
  "longitude" decimal(10,7),
  "location_name" varchar(255),
  "user_id" integer NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT now(),
  "updated_at" timestamp NOT NULL DEFAULT now()
);

CREATE TABLE "comments" (
  "id" integer PRIMARY KEY,
  "body" text NOT NULL,
  "user_id" integer NOT NULL,
  "post_id" integer NOT NULL,
  "parent_comment_id" integer,
  "created_at" timestamp NOT NULL DEFAULT now(),
  "updated_at" timestamp NOT NULL DEFAULT now()
);

CREATE TABLE "reactions" (
  "id" integer PRIMARY KEY,
  "type" varchar(20) NOT NULL CHECK (type IN ('like', 'love', 'funny', 'sad', 'angry', 'wow')),
  "user_id" integer NOT NULL,
  "post_id" integer NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT now(),
  UNIQUE ("user_id", "post_id")
);

ALTER TABLE "posts" ADD CONSTRAINT "user_posts" FOREIGN KEY ("user_id") REFERENCES "users" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follows" ADD FOREIGN KEY ("following_user_id") REFERENCES "users" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "follows" ADD FOREIGN KEY ("followed_user_id") REFERENCES "users" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "comments" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "comments" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "comments" ADD FOREIGN KEY ("parent_comment_id") REFERENCES "comments" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "reactions" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "reactions" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id") DEFERRABLE INITIALLY IMMEDIATE;

CREATE INDEX ON "posts" ("user_id", "created_at" DESC);

CREATE INDEX ON "follows" ("followed_user_id");

CREATE INDEX ON "comments" ("post_id");

CREATE INDEX ON "reactions" ("post_id");
