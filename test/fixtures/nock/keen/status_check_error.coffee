response = {"page":{"id":"z3mvdbpvy7yh","name":"Keen IO","url":"http://status.keen.io"},"status":{"indicator":"minor","description":"Partially Degraded Service"},"components":[{"status":"operational","name":"Data Collection API","created_at":"2013-07-23T18:44:56.207Z","updated_at":"2015-02-19T04:34:26.123Z","position":1,"description":null,"group_id":null,"id":"19fvy2vdltdq","page_id":"z3mvdbpvy7yh"},{"status":"degraded_performance","name":"Data Analysis API","created_at":"2013-07-23T18:44:56.224Z","updated_at":"2015-02-19T14:31:51.487Z","position":2,"description":null,"group_id":null,"id":"m4dlvtqlms48","page_id":"z3mvdbpvy7yh"},{"status":"operational","name":"Keen Website","created_at":"2014-01-28T22:14:48.488Z","updated_at":"2014-11-05T20:12:32.499Z","position":3,"description":"Public website and project dashboard.","group_id":null,"id":"mkc9379vn1qm","page_id":"z3mvdbpvy7yh"}],"incidents":[{"name":"Query Durations are Up for our Dallas data centre","status":"identified","created_at":"2015-02-19T06:31:53.247-08:00","updated_at":"2015-02-19T12:40:03.358-08:00","monitoring_at":null,"resolved_at":null,"impact":"minor","shortlink":"http://stspg.io/qp4","postmortem_ignored":false,"postmortem_body":null,"postmortem_body_last_updated_at":null,"postmortem_published_at":null,"postmortem_notified_subscribers":false,"postmortem_notified_twitter":false,"backfilled":false,"scheduled_for":null,"scheduled_until":null,"scheduled_remind_prior":false,"scheduled_reminded_at":null,"impact_override":null,"scheduled_auto_in_progress":false,"scheduled_auto_completed":false,"id":"4d0g5889svvp","page_id":"z3mvdbpvy7yh","incident_updates":[{"status":"identified","body":"New data is now flowing in efficiently and ready for querying within minutes. We identified that a chunk of yesterday's data did not get written to disk, and we are very sorry for that. Our first data loss in 12 months. We are still experiencing query instability for some customers.","created_at":"2015-02-19T12:39:58.416-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T20:39:58.708Z","updated_at":"2015-02-19T12:39:58.708-08:00","display_at":"2015-02-19T12:39:58.416-08:00","id":"jxnjrgc7v1v6","incident_id":"4d0g5889svvp"},{"status":"identified","body":"Still experiencing query instability. Data collection is up but delayed. We are making progress on the backlog and are currently adding additional hardware to help with this effort.","created_at":"2015-02-19T11:31:57.158-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T19:31:57.558Z","updated_at":"2015-02-19T11:31:57.558-08:00","display_at":"2015-02-19T11:31:57.158-08:00","id":"l5wmjrzd10w4","incident_id":"4d0g5889svvp"},{"status":"identified","body":"We are disabling delete API calls in our remaining DC as an emergency measure as we continue to work on query durations.","created_at":"2015-02-19T10:49:21.354-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T18:49:21.835Z","updated_at":"2015-02-19T10:49:21.835-08:00","display_at":"2015-02-19T10:49:21.354-08:00","id":"p2h0xhmbrsxr","incident_id":"4d0g5889svvp"},{"status":"identified","body":"We're continuing to work on our query durations. We're specifically working on changing our post-write optimization systems which have been disabled and need to complete their backlog.","created_at":"2015-02-19T10:03:05.794-08:00","wants_twitter_update":false,"twitter_updated_at":null,"updated_at":"2015-02-19T10:03:05.794-08:00","display_at":"2015-02-19T10:03:05.794-08:00","id":"w8jf2dcv4fy0","incident_id":"4d0g5889svvp"},{"status":"identified","body":"We are continuing to work on our write path and are seeing high durations of queries in one DC. We are disabling delete API calls in one DC as an emergency measure.","created_at":"2015-02-19T09:33:38.179-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T17:33:38.448Z","updated_at":"2015-02-19T09:33:38.448-08:00","display_at":"2015-02-19T09:33:38.179-08:00","id":"dp4qr2fpz70k","incident_id":"4d0g5889svvp"},{"status":"identified","body":"Query durations continue to be high in one of our DCs. We've shifted traffic to balance our data centers to try and balance the durations. We're also investigating increasingly high query times in our storage layer which we suspect may be related to changes in our write path from yesterday's event. We're currently working on that problem and preparing to add more capacity later today!","created_at":"2015-02-19T08:53:56.068-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T16:53:56.331Z","updated_at":"2015-02-19T08:53:56.331-08:00","display_at":"2015-02-19T08:53:56.068-08:00","id":"vgqt9d4qtmcq","incident_id":"4d0g5889svvp"},{"status":"identified","body":"We've deployed some changes to balance the query load more evenly and are working on increasing capacity. Query durations are improving as a results of this effort, but we still have work to do.","created_at":"2015-02-19T07:56:50.706-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T15:56:51.058Z","updated_at":"2015-02-19T07:56:51.058-08:00","display_at":"2015-02-19T07:56:50.706-08:00","id":"kpsypsw8zgxx","incident_id":"4d0g5889svvp"},{"status":"investigating","body":"We are investigating increased query durations. Not all customers should be affected. Writes are not impacted.","created_at":"2015-02-19T06:31:53.435-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T14:31:53.726Z","updated_at":"2015-02-19T06:31:53.726-08:00","display_at":"2015-02-19T06:31:53.435-08:00","id":"9k1b091n5ds3","incident_id":"4d0g5889svvp"}],"components":[{"status":"operational","name":"Data Collection API","created_at":"2013-07-23T18:44:56.207Z","updated_at":"2015-02-19T04:34:26.123Z","position":1,"description":null,"group_id":null,"id":"19fvy2vdltdq","page_id":"z3mvdbpvy7yh"},{"status":"degraded_performance","name":"Data Analysis API","created_at":"2013-07-23T18:44:56.224Z","updated_at":"2015-02-19T14:31:51.487Z","position":2,"description":null,"group_id":null,"id":"m4dlvtqlms48","page_id":"z3mvdbpvy7yh"}]},{"name":"Increased query latency","status":"resolved","created_at":"2015-02-19T00:16:46.766-08:00","updated_at":"2015-02-19T03:49:31.021-08:00","monitoring_at":null,"resolved_at":"2015-02-19T03:49:29.147-08:00","impact":"major","shortlink":"http://stspg.io/qnH","postmortem_ignored":false,"postmortem_body":null,"postmortem_body_last_updated_at":null,"postmortem_published_at":null,"postmortem_notified_subscribers":false,"postmortem_notified_twitter":false,"backfilled":false,"scheduled_for":null,"scheduled_until":null,"scheduled_remind_prior":false,"scheduled_reminded_at":null,"impact_override":null,"scheduled_auto_in_progress":false,"scheduled_auto_completed":false,"id":"75bqpzww81yr","page_id":"z3mvdbpvy7yh","incident_updates":[{"status":"resolved","body":"We’ve brought the query latency back to normal levels.","created_at":"2015-02-19T03:49:29.147-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T11:49:29.510Z","updated_at":"2015-02-19T03:49:29.510-08:00","display_at":"2015-02-19T03:49:29.147-08:00","id":"c314r557d6zb","incident_id":"75bqpzww81yr"},{"status":"identified","body":"We’ve identified a problem with our query latency and are taking steps to resolve it.","created_at":"2015-02-19T02:11:09.564-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T10:11:09.995Z","updated_at":"2015-02-19T02:11:09.995-08:00","display_at":"2015-02-19T02:11:09.564-08:00","id":"mxq98jzdy4sy","incident_id":"75bqpzww81yr"},{"status":"investigating","body":"We’re investigating a problem that’s causing increased query latency for many of our customers, and working hard to resolve this issue!","created_at":"2015-02-19T00:51:04.486-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T08:51:04.898Z","updated_at":"2015-02-19T00:51:04.898-08:00","display_at":"2015-02-19T00:51:04.486-08:00","id":"tz9328zgx6jf","incident_id":"75bqpzww81yr"},{"status":"identified","body":"We’re currently experiencing some increased query latency for some customers. We’ve identified the problem and are working to remedy it.","created_at":"2015-02-19T00:16:46.926-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T08:16:47.279Z","updated_at":"2015-02-19T00:16:47.279-08:00","display_at":"2015-02-19T00:16:46.926-08:00","id":"m76r49jgq7lb","incident_id":"75bqpzww81yr"}],"components":[]},{"name":"Partial outage writing events","status":"resolved","created_at":"2015-02-18T13:06:13.076-08:00","updated_at":"2015-02-18T20:34:29.552-08:00","monitoring_at":null,"resolved_at":"2015-02-18T20:34:26.065-08:00","impact":"major","shortlink":"http://stspg.io/qjo","postmortem_ignored":false,"postmortem_body":null,"postmortem_body_last_updated_at":null,"postmortem_published_at":null,"postmortem_notified_subscribers":false,"postmortem_notified_twitter":false,"backfilled":false,"scheduled_for":null,"scheduled_until":null,"scheduled_remind_prior":false,"scheduled_reminded_at":null,"impact_override":null,"scheduled_auto_in_progress":false,"scheduled_auto_completed":false,"id":"vc71tck213ds","page_id":"z3mvdbpvy7yh","incident_updates":[{"status":"resolved","body":"All incoming events are being processed normally. We will continue to keep a close eye out and work on providing more detailed information.","created_at":"2015-02-18T20:34:26.065-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T04:34:26.780Z","updated_at":"2015-02-18T20:34:26.780-08:00","display_at":"2015-02-18T20:34:26.065-08:00","id":"1631d172h1yn","incident_id":"vc71tck213ds"},{"status":"identified","body":"We're seeing improvements with query performance while continuing to work on the backlog of events from earlier.","created_at":"2015-02-18T19:25:00.486-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T03:25:00.860Z","updated_at":"2015-02-18T19:25:00.860-08:00","display_at":"2015-02-18T19:25:00.486-08:00","id":"3279pv3tyq10","incident_id":"vc71tck213ds"},{"status":"identified","body":"We're making good progress on getting the write path back up and stable,  but some queries from the West Coast are now failing. We're in the process of shifting query traffic to fix those failures.","created_at":"2015-02-18T18:39:37.884-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T02:39:38.382Z","updated_at":"2015-02-18T18:56:21.506-08:00","display_at":"2015-02-18T18:39:00.000-08:00","id":"9n7cbjvk39q6","incident_id":"vc71tck213ds"},{"status":"identified","body":"We're continuing to process the written event backlog in our Dallas datacenter. We are receiving and safely storing events in San Jose, but the insert time is slow enough that you may still see failures (which is our system letting you know we didn't safely store it). We are rehabilitating the infrastructure in San Jose to process those queued events and make them available for querying. Thank you so much for your patience.","created_at":"2015-02-18T18:22:39.183-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T02:22:39.501Z","updated_at":"2015-02-18T18:22:39.501-08:00","display_at":"2015-02-18T18:22:39.183-08:00","id":"mrx1tv4n2lhy","incident_id":"vc71tck213ds"},{"status":"identified","body":"We've rolled out our Write Path infrastructure to the functional datacenter and the backlog of received events is now being processed again. We're continuing to tackle this!","created_at":"2015-02-18T17:09:45.315-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-19T01:09:46.270Z","updated_at":"2015-02-18T17:09:46.270-08:00","display_at":"2015-02-18T17:09:45.315-08:00","id":"tjmxt8dh0yy6","incident_id":"vc71tck213ds"},{"status":"identified","body":"All incoming event write requests to our San Jose datacenter are currently being rejected. Writes to our Dallas datacenter are still being queued. This means some customers will be experiencing failed writes.","created_at":"2015-02-18T15:55:36.490-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-18T23:55:36.814Z","updated_at":"2015-02-18T15:55:36.814-08:00","display_at":"2015-02-18T15:55:36.490-08:00","id":"9d63kzdpjhh7","incident_id":"vc71tck213ds"},{"status":"identified","body":"We're still experiencing an outage with the part of our infrastructure responsible for making new incoming events available for queries. We're approximately one hour delayed in persisting your data. All hands are on deck to fix this for you!","created_at":"2015-02-18T15:12:43.630-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-18T23:12:44.116Z","updated_at":"2015-02-18T15:12:44.116-08:00","display_at":"2015-02-18T15:12:43.630-08:00","id":"dyvf1wtfjxf2","incident_id":"vc71tck213ds"},{"status":"identified","body":"We’re continuing our work to solve this problem and will continue posting updates as the situation progresses.","created_at":"2015-02-18T14:18:22.984-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-18T22:18:23.325Z","updated_at":"2015-02-18T14:18:23.325-08:00","display_at":"2015-02-18T14:18:22.984-08:00","id":"s0dfbmrmw4ht","incident_id":"vc71tck213ds"},{"status":"identified","body":"We’ve identified the problem in our write path and are working hard to solve it.","created_at":"2015-02-18T13:42:54.136-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-18T21:42:54.417Z","updated_at":"2015-02-18T13:42:54.417-08:00","display_at":"2015-02-18T13:42:54.136-08:00","id":"jxmtc1ynzrlb","incident_id":"vc71tck213ds"},{"status":"investigating","body":"We are seeing elevated write times to our San Jose datacenter.  The team is continuing to triage and work on the issue.","created_at":"2015-02-18T13:12:35.137-08:00","wants_twitter_update":false,"twitter_updated_at":null,"updated_at":"2015-02-18T13:12:35.137-08:00","display_at":"2015-02-18T13:12:35.137-08:00","id":"yyvyv1sjvfmq","incident_id":"vc71tck213ds"},{"status":"investigating","body":"We are currently experiencing issues writing events to keen.io.  The team is investigating.","created_at":"2015-02-18T13:06:13.273-08:00","wants_twitter_update":false,"twitter_updated_at":null,"updated_at":"2015-02-18T13:06:13.273-08:00","display_at":"2015-02-18T13:06:13.273-08:00","id":"nl8jc6fksjww","incident_id":"vc71tck213ds"}],"components":[{"status":"operational","name":"Data Collection API","created_at":"2013-07-23T18:44:56.207Z","updated_at":"2015-02-19T04:34:26.123Z","position":1,"description":null,"group_id":null,"id":"19fvy2vdltdq","page_id":"z3mvdbpvy7yh"},{"status":"degraded_performance","name":"Data Analysis API","created_at":"2013-07-23T18:44:56.224Z","updated_at":"2015-02-19T14:31:51.487Z","position":2,"description":null,"group_id":null,"id":"m4dlvtqlms48","page_id":"z3mvdbpvy7yh"}]},{"name":"Query Durations are Up","status":"postmortem","created_at":"2015-02-17T17:27:39.440-08:00","updated_at":"2015-02-18T09:42:59.183-08:00","monitoring_at":null,"resolved_at":"2015-02-17T17:41:39.577-08:00","impact":"minor","shortlink":"http://stspg.io/qch","postmortem_ignored":false,"postmortem_body":"It has been a tough couple of months for query performance at keen.io.  In the spirit of transparency and providing more context, we've written a full update here: https://keen.io/blog/111360878761/query-performance-update  Please take the time to read it to gain a better perspective on the performance issues that we have been having.","postmortem_body_last_updated_at":"2015-02-18T17:41:55.338Z","postmortem_published_at":"2015-02-18T17:42:59.112Z","postmortem_notified_subscribers":false,"postmortem_notified_twitter":false,"backfilled":false,"scheduled_for":null,"scheduled_until":null,"scheduled_remind_prior":false,"scheduled_reminded_at":null,"impact_override":null,"scheduled_auto_in_progress":false,"scheduled_auto_completed":false,"id":"b31d8j6fwjq1","page_id":"z3mvdbpvy7yh","incident_updates":[{"status":"postmortem","body":"It has been a tough couple of months for query performance at keen.io.  In the spirit of transparency and providing more context, we've written a full update here: https://keen.io/blog/111360878761/query-performance-update  Please take the time to read it to gain a better perspective on the performance issues that we have been having.","created_at":"2015-02-18T09:42:59.181-08:00","wants_twitter_update":false,"twitter_updated_at":null,"updated_at":"2015-02-18T09:42:59.181-08:00","display_at":"2015-02-18T09:42:59.181-08:00","id":"2rcdyxn52046","incident_id":"b31d8j6fwjq1"},{"status":"resolved","body":"Query durations are back to normal. We are continuing to monitor and are working on improving Query stability.","created_at":"2015-02-17T17:41:39.577-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-18T01:41:40.055Z","updated_at":"2015-02-17T17:41:40.055-08:00","display_at":"2015-02-17T17:41:39.577-08:00","id":"2kjfybyb9s1b","incident_id":"b31d8j6fwjq1"},{"status":"investigating","body":"We are investigating another incident with higher than usual query durations.","created_at":"2015-02-17T17:27:39.587-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-18T01:27:39.918Z","updated_at":"2015-02-17T17:27:39.918-08:00","display_at":"2015-02-17T17:27:39.587-08:00","id":"hxq40dbw140w","incident_id":"b31d8j6fwjq1"}],"components":[{"status":"degraded_performance","name":"Data Analysis API","created_at":"2013-07-23T18:44:56.224Z","updated_at":"2015-02-19T14:31:51.487Z","position":2,"description":null,"group_id":null,"id":"m4dlvtqlms48","page_id":"z3mvdbpvy7yh"}]},{"name":"Datastore servicing","status":"postmortem","created_at":"2015-02-17T12:55:55.387-08:00","updated_at":"2015-02-17T16:05:07.373-08:00","monitoring_at":null,"resolved_at":"2015-02-17T15:03:13.815-08:00","impact":"minor","shortlink":"http://stspg.io/qbA","postmortem_ignored":false,"postmortem_body":"Usage patterns pushed us to capacity and after some debugging the query pattern ended and durations settled to normal.\r\n\r\nAs this event calmed down we doubled the capacity of our query processing API and increased backend query workers by 33% in hopes of preventing further slowdowns. We're also continuing to work on an internal rate limiting problem to prevent this from occurring.\r\n\r\nWe apologize for the inconvenience and appreciate you bearing with us during these problems!","postmortem_body_last_updated_at":"2015-02-18T00:04:52.061Z","postmortem_published_at":"2015-02-18T00:05:06.797Z","postmortem_notified_subscribers":false,"postmortem_notified_twitter":true,"backfilled":false,"scheduled_for":null,"scheduled_until":null,"scheduled_remind_prior":false,"scheduled_reminded_at":null,"impact_override":null,"scheduled_auto_in_progress":false,"scheduled_auto_completed":false,"id":"f3zc2ycq0pb6","page_id":"z3mvdbpvy7yh","incident_updates":[{"status":"postmortem","body":"Usage patterns pushed us to capacity and after some debugging the query pattern ended and durations settled to normal.\r\n\r\nAs this event calmed down we doubled the capacity of our query processing API and increased backend query workers by 33% in hopes of preventing further slowdowns. We're also continuing to work on an internal rate limiting problem to prevent this from occurring.\r\n\r\nWe apologize for the inconvenience and appreciate you bearing with us during these problems!","created_at":"2015-02-17T16:05:06.861-08:00","wants_twitter_update":false,"twitter_updated_at":"2015-02-18T00:05:07.295Z","updated_at":"2015-02-17T16:05:07.295-08:00","display_at":"2015-02-17T16:05:06.861-08:00","id":"pc6tl5rs8n89","incident_id":"f3zc2ycq0pb6"},{"status":"resolved","body":"Query durations have returned to normal levels. We are continuing to deploy more capacity now that incident has completed in an effort to prevent further slowdowns.","created_at":"2015-02-17T15:03:13.815-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T23:03:14.425Z","updated_at":"2015-02-17T15:03:14.425-08:00","display_at":"2015-02-17T15:03:13.815-08:00","id":"pwtd7ypzgj6x","incident_id":"f3zc2ycq0pb6"},{"status":"investigating","body":"We are still working on deploying more capacity as well as researching the root cause of query slowdowns.","created_at":"2015-02-17T14:44:22.270-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T22:44:22.609Z","updated_at":"2015-02-17T14:44:22.609-08:00","display_at":"2015-02-17T14:44:22.270-08:00","id":"hkmpl4y81fkp","incident_id":"f3zc2ycq0pb6"},{"status":"investigating","body":"We're continuing to investigate the root cause and are currently deploying more capacity for reads to try and bring down overall durations.","created_at":"2015-02-17T13:45:23.206-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T21:45:23.516Z","updated_at":"2015-02-17T13:45:23.516-08:00","display_at":"2015-02-17T13:45:23.206-08:00","id":"wx1f6yjy7vt0","incident_id":"f3zc2ycq0pb6"},{"status":"investigating","body":"We are currently experiencing increased response times on our API.  The team is working on the issue.","created_at":"2015-02-17T13:12:42.933-08:00","wants_twitter_update":false,"twitter_updated_at":null,"updated_at":"2015-02-17T13:12:42.933-08:00","display_at":"2015-02-17T13:12:42.933-08:00","id":"hmr8krxfb87k","incident_id":"f3zc2ycq0pb6"},{"status":"investigating","body":"We are making some minor changes to our storage backend which may cause a minor service issue.   This is expected to be completed within the next 30 minutes.","created_at":"2015-02-17T12:55:55.561-08:00","wants_twitter_update":false,"twitter_updated_at":null,"updated_at":"2015-02-17T12:55:55.561-08:00","display_at":"2015-02-17T12:55:55.561-08:00","id":"skd2zgjqm338","incident_id":"f3zc2ycq0pb6"}],"components":[]},{"name":"Query durations are high.","status":"resolved","created_at":"2015-02-17T11:28:32.239-08:00","updated_at":"2015-02-17T12:09:04.260-08:00","monitoring_at":"2015-02-17T11:35:42.616-08:00","resolved_at":"2015-02-17T11:37:49.028-08:00","impact":"minor","shortlink":"http://stspg.io/qaS","postmortem_ignored":true,"postmortem_body":null,"postmortem_body_last_updated_at":null,"postmortem_published_at":null,"postmortem_notified_subscribers":false,"postmortem_notified_twitter":false,"backfilled":false,"scheduled_for":null,"scheduled_until":null,"scheduled_remind_prior":false,"scheduled_reminded_at":null,"impact_override":null,"scheduled_auto_in_progress":false,"scheduled_auto_completed":false,"id":"5wxwh66p3kj5","page_id":"z3mvdbpvy7yh","incident_updates":[{"status":"resolved","body":"Query durations have returned to normal.","created_at":"2015-02-17T11:37:49.028-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T19:37:49.582Z","updated_at":"2015-02-17T11:37:49.582-08:00","display_at":"2015-02-17T11:37:49.028-08:00","id":"3y1jtx9wsvb9","incident_id":"5wxwh66p3kj5"},{"status":"monitoring","body":"Query durations are returning to normal. We will continue to monitor the times!","created_at":"2015-02-17T11:35:42.616-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T19:35:43.195Z","updated_at":"2015-02-17T11:35:43.195-08:00","display_at":"2015-02-17T11:35:42.616-08:00","id":"glzkxwr7zwn5","incident_id":"5wxwh66p3kj5"},{"status":"investigating","body":"We're seeing increased query durations. We are investigating a storage issue that may be the cause.","created_at":"2015-02-17T11:28:32.416-08:00","wants_twitter_update":false,"twitter_updated_at":null,"updated_at":"2015-02-17T11:28:32.416-08:00","display_at":"2015-02-17T11:28:32.416-08:00","id":"kx1scn18yysc","incident_id":"5wxwh66p3kj5"}],"components":[]},{"name":"Query durations are up","status":"resolved","created_at":"2015-02-17T06:42:30.538-08:00","updated_at":"2015-02-17T07:09:52.694-08:00","monitoring_at":null,"resolved_at":"2015-02-17T07:09:46.347-08:00","impact":"minor","shortlink":"http://stspg.io/qXg","postmortem_ignored":true,"postmortem_body":null,"postmortem_body_last_updated_at":null,"postmortem_published_at":null,"postmortem_notified_subscribers":false,"postmortem_notified_twitter":false,"backfilled":false,"scheduled_for":null,"scheduled_until":null,"scheduled_remind_prior":false,"scheduled_reminded_at":null,"impact_override":null,"scheduled_auto_in_progress":false,"scheduled_auto_completed":false,"id":"kwzh8b4xmxtp","page_id":"z3mvdbpvy7yh","incident_updates":[{"status":"resolved","body":"We're seeing normal query durations after making adjustments to query scheduling.","created_at":"2015-02-17T07:09:46.347-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T15:09:46.789Z","updated_at":"2015-02-17T07:09:46.789-08:00","display_at":"2015-02-17T07:09:46.347-08:00","id":"n48jh818rpgz","incident_id":"kwzh8b4xmxtp"},{"status":"investigating","body":"We've made some changes to query scheduling and are seeing an improvement in overall query durations. We're continuing to monitor.","created_at":"2015-02-17T07:05:27.570-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T15:05:27.902Z","updated_at":"2015-02-17T07:05:27.902-08:00","display_at":"2015-02-17T07:05:27.570-08:00","id":"gql55jt6ybzs","incident_id":"kwzh8b4xmxtp"},{"status":"investigating","body":"We're investigating high query durations for some customers.","created_at":"2015-02-17T06:42:30.661-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T14:42:31.109Z","updated_at":"2015-02-17T06:42:31.109-08:00","display_at":"2015-02-17T06:42:30.661-08:00","id":"75mb2gl6g842","incident_id":"kwzh8b4xmxtp"}],"components":[]},{"name":"Query durations are up","status":"postmortem","created_at":"2015-02-16T16:51:58.863-08:00","updated_at":"2015-02-16T18:58:24.424-08:00","monitoring_at":"2015-02-16T18:42:54.122-08:00","resolved_at":"2015-02-16T18:50:03.437-08:00","impact":"minor","shortlink":"http://stspg.io/qUJ","postmortem_ignored":false,"postmortem_body":"At 3:34PM PST our query durations began to spike. Multiple incidents seemed to coincide:\r\n* A number of our application servers began to run out of memory\r\n* A large number of queries began to be queued, raising the average duration\r\n\r\nWe initially reacted to the memory problems, as we'd seen this pattern recently and mistakenly associated the memory failure with the query durations.  At this point all of our on-call staff and many other team members were in attendance.\r\n\r\nAfter watching query durations improve slightly we realized this wasn't all of the issue. We began to investigate continued problems. We initially suspected a new query dispatcher and spent some time rolling back to an older mechanism. This turned out to be a non-issue.\r\n\r\nAt 6:00PM PST Finally we isolated a query pattern that was causing an unhealthy number of queue backups and isolated the customer. After some manual query queue flushing, we were able to quickly return to normal operation at 6:50PM PST.\r\n\r\nWe will be deploying more capacity tomorrow in an attempt to have fewer issues with this type of query pattern in the future. We will also be beginning a project to improve the responsiveness of our rate limiting.\r\n\r\nWe're very sorry for the duration and depth of this issue. The large number of incidents lately is something we do not take lightly and we will be posting additional post mortem information as well as periodic explanations of work we are deploying to mitigate future issues and to continue to earn your trust!","postmortem_body_last_updated_at":"2015-02-17T02:58:17.086Z","postmortem_published_at":"2015-02-17T02:58:22.794Z","postmortem_notified_subscribers":true,"postmortem_notified_twitter":true,"backfilled":false,"scheduled_for":null,"scheduled_until":null,"scheduled_remind_prior":false,"scheduled_reminded_at":null,"impact_override":null,"scheduled_auto_in_progress":false,"scheduled_auto_completed":false,"id":"lm3r43kx7qjq","page_id":"z3mvdbpvy7yh","incident_updates":[{"status":"postmortem","body":"At 3:34PM PST our query durations began to spike. Multiple incidents seemed to coincide:\r\n* A number of our application servers began to run out of memory\r\n* A large number of queries began to be queued, raising the average duration\r\n\r\nWe initially reacted to the memory problems, as we'd seen this pattern recently and mistakenly associated the memory failure with the query durations.  At this point all of our on-call staff and many other team members were in attendance.\r\n\r\nAfter watching query durations improve slightly we realized this wasn't all of the issue. We began to investigate continued problems. We initially suspected a new query dispatcher and spent some time rolling back to an older mechanism. This turned out to be a non-issue.\r\n\r\nAt 6:00PM PST Finally we isolated a query pattern that was causing an unhealthy number of queue backups and isolated the customer. After some manual query queue flushing, we were able to quickly return to normal operation at 6:50PM PST.\r\n\r\nWe will be deploying more capacity tomorrow in an attempt to have fewer issues with this type of query pattern in the future. We will also be beginning a project to improve the responsiveness of our rate limiting.\r\n\r\nWe're very sorry for the duration and depth of this issue. The large number of incidents lately is something we do not take lightly and we will be posting additional post mortem information as well as periodic explanations of work we are deploying to mitigate future issues and to continue to earn your trust!","created_at":"2015-02-16T18:58:22.857-08:00","wants_twitter_update":false,"twitter_updated_at":"2015-02-17T02:58:23.457Z","updated_at":"2015-02-16T18:58:23.457-08:00","display_at":"2015-02-16T18:58:22.857-08:00","id":"0s1151bfnwmz","incident_id":"lm3r43kx7qjq"},{"status":"resolved","body":"Query durations hare returned to normal.","created_at":"2015-02-16T18:50:03.437-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T02:50:03.897Z","updated_at":"2015-02-16T18:50:03.897-08:00","display_at":"2015-02-16T18:50:03.437-08:00","id":"ls7ml3d9wr8n","incident_id":"lm3r43kx7qjq"},{"status":"monitoring","body":"We are seeing a positive change in query durations and are continuing to monitor.","created_at":"2015-02-16T18:42:54.122-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T02:42:54.529Z","updated_at":"2015-02-16T18:42:54.529-08:00","display_at":"2015-02-16T18:42:54.122-08:00","id":"zpsjrx2ns2wh","incident_id":"lm3r43kx7qjq"},{"status":"investigating","body":"We have take some steps to protect our query backend from an odd query pattern, rolled back to an older query-dispatch mechanism and are now monitoring the effect of these changes. We are aggressively timing out queries until we can monitor new query durations.  This is still only affecting customers in the midwest and east coast.","created_at":"2015-02-16T18:24:39.749-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T02:24:40.070Z","updated_at":"2015-02-16T18:24:40.070-08:00","display_at":"2015-02-16T18:24:39.749-08:00","id":"7rd9vs3b5wsc","incident_id":"lm3r43kx7qjq"},{"status":"investigating","body":"We are now working to add capacity to our query analysis path in an attempt to compensate for the query duration slowdown.","created_at":"2015-02-16T17:53:04.308-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T01:53:04.596Z","updated_at":"2015-02-16T17:53:04.596-08:00","display_at":"2015-02-16T17:53:04.308-08:00","id":"03w346ccw5f2","incident_id":"lm3r43kx7qjq"},{"status":"investigating","body":"We are continuing to investigate the cause of the slowdown. We've eliminated some parts of our stack and are investigating timeout behavior for long running queries. Our primary and secondary on calls as well as a few other team members are all actively investigating.","created_at":"2015-02-16T17:23:48.547-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T01:23:48.938Z","updated_at":"2015-02-16T17:23:48.938-08:00","display_at":"2015-02-16T17:23:48.547-08:00","id":"5lyp83qt84nc","incident_id":"lm3r43kx7qjq"},{"status":"investigating","body":"We've been experiencing high query durations since approximately 3:43P PST.  The impact seems to be only to midwest and east coast customers at present.","created_at":"2015-02-16T16:51:59.006-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-17T00:51:59.389Z","updated_at":"2015-02-16T16:51:59.389-08:00","display_at":"2015-02-16T16:51:59.006-08:00","id":"0k5zzlcnrt11","incident_id":"lm3r43kx7qjq"}],"components":[]},{"name":"Increased query durations for some customers","status":"resolved","created_at":"2015-02-12T09:22:25.072-08:00","updated_at":"2015-02-12T14:47:45.496-08:00","monitoring_at":null,"resolved_at":"2015-02-12T14:47:44.015-08:00","impact":"minor","shortlink":"http://stspg.io/pxk","postmortem_ignored":false,"postmortem_body":null,"postmortem_body_last_updated_at":null,"postmortem_published_at":null,"postmortem_notified_subscribers":false,"postmortem_notified_twitter":false,"backfilled":false,"scheduled_for":null,"scheduled_until":null,"scheduled_remind_prior":false,"scheduled_reminded_at":null,"impact_override":null,"scheduled_auto_in_progress":false,"scheduled_auto_completed":false,"id":"jpfqzb4jwzgk","page_id":"z3mvdbpvy7yh","incident_updates":[{"status":"resolved","body":"Query durations have returned to normal levels across the board for all Keen customers.","created_at":"2015-02-12T14:47:44.015-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-12T22:47:44.368Z","updated_at":"2015-02-12T14:47:44.368-08:00","display_at":"2015-02-12T14:47:44.015-08:00","id":"gpdwxyq68g9s","incident_id":"jpfqzb4jwzgk"},{"status":"investigating","body":"Normal service has been restored in one of our data centers, and we’re working on bringing it back across the board.","created_at":"2015-02-12T14:08:03.874-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-12T22:08:04.340Z","updated_at":"2015-02-12T14:08:04.340-08:00","display_at":"2015-02-12T14:08:03.874-08:00","id":"7vs15xj04p3m","incident_id":"jpfqzb4jwzgk"},{"status":"investigating","body":"Reliability is important to our team, and we’re taking this issue seriously. We’ll update this space as our investigation turns up more.","created_at":"2015-02-12T13:34:14.485-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-12T21:34:14.834Z","updated_at":"2015-02-12T13:34:14.834-08:00","display_at":"2015-02-12T13:34:14.485-08:00","id":"x31qvttck45w","incident_id":"jpfqzb4jwzgk"},{"status":"investigating","body":"Our platform team is hard at work tracking down the source of the trouble in our analysis stack.","created_at":"2015-02-12T13:05:45.249-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-12T21:05:45.569Z","updated_at":"2015-02-12T13:05:45.569-08:00","display_at":"2015-02-12T13:05:45.249-08:00","id":"tjvhc4c2zky9","incident_id":"jpfqzb4jwzgk"},{"status":"investigating","body":"Working hard to find the root cause – still looking!","created_at":"2015-02-12T12:35:48.681-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-12T20:35:48.962Z","updated_at":"2015-02-12T12:35:48.962-08:00","display_at":"2015-02-12T12:35:48.681-08:00","id":"162h20750t0l","incident_id":"jpfqzb4jwzgk"},{"status":"investigating","body":"The analysis API performance is improving but still degraded. Our investigation continues.","created_at":"2015-02-12T11:41:34.523-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-12T19:41:34.793Z","updated_at":"2015-02-12T11:41:34.793-08:00","display_at":"2015-02-12T11:41:34.523-08:00","id":"b38zt3wtq74p","incident_id":"jpfqzb4jwzgk"},{"status":"investigating","body":"Our data analysis API is temporarily unavailable to some customers. We are continuing investigation into the root cause.","created_at":"2015-02-12T10:18:24.337-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-12T18:18:24.628Z","updated_at":"2015-02-12T10:18:24.628-08:00","display_at":"2015-02-12T10:18:24.337-08:00","id":"t28x1s64601d","incident_id":"jpfqzb4jwzgk"},{"status":"investigating","body":"We are continuing to look for the root cause of high query durations.","created_at":"2015-02-12T09:58:33.763-08:00","wants_twitter_update":false,"twitter_updated_at":null,"updated_at":"2015-02-12T09:58:33.763-08:00","display_at":"2015-02-12T09:58:33.763-08:00","id":"11nb6z7cr4ry","incident_id":"jpfqzb4jwzgk"},{"status":"investigating","body":"We're seeing high query times for some customers. We're investigating!","created_at":"2015-02-12T09:22:25.227-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-12T17:22:25.544Z","updated_at":"2015-02-12T09:22:25.544-08:00","display_at":"2015-02-12T09:22:25.227-08:00","id":"2t1sqrjzd4dp","incident_id":"jpfqzb4jwzgk"}],"components":[]},{"name":"Delayed Query Availability of Events","status":"resolved","created_at":"2015-02-09T12:47:18.547-08:00","updated_at":"2015-02-09T13:08:31.847-08:00","monitoring_at":"2015-02-09T12:58:58.373-08:00","resolved_at":"2015-02-09T13:08:22.207-08:00","impact":"none","shortlink":"http://stspg.io/pVv","postmortem_ignored":true,"postmortem_body":null,"postmortem_body_last_updated_at":null,"postmortem_published_at":null,"postmortem_notified_subscribers":false,"postmortem_notified_twitter":false,"backfilled":false,"scheduled_for":null,"scheduled_until":null,"scheduled_remind_prior":false,"scheduled_reminded_at":null,"impact_override":null,"scheduled_auto_in_progress":false,"scheduled_auto_completed":false,"id":"7fjyvjk9mz9c","page_id":"z3mvdbpvy7yh","incident_updates":[{"status":"resolved","body":"We've completed the maintenance and the time between event writes and their availability for querying has returned to normal.","created_at":"2015-02-09T13:08:22.207-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-09T21:08:22.706Z","updated_at":"2015-02-09T13:08:22.706-08:00","display_at":"2015-02-09T13:08:22.207-08:00","id":"7lzklz22359c","incident_id":"7fjyvjk9mz9c"},{"status":"monitoring","body":"A fix has been implemented and we are monitoring the results.","created_at":"2015-02-09T12:58:58.373-08:00","wants_twitter_update":false,"twitter_updated_at":null,"updated_at":"2015-02-09T12:58:58.373-08:00","display_at":"2015-02-09T12:58:58.373-08:00","id":"bymd7dnwv996","incident_id":"7fjyvjk9mz9c"},{"status":"identified","body":"We are doing a minor upgrade to software, and expect a slight delay in making events available. We are monitoring and expect this to be a short-lived interruption.","created_at":"2015-02-09T12:47:18.708-08:00","wants_twitter_update":true,"twitter_updated_at":"2015-02-09T20:47:18.992Z","updated_at":"2015-02-09T12:47:18.992-08:00","display_at":"2015-02-09T12:47:18.708-08:00","id":"2f2pp6s2lzxj","incident_id":"7fjyvjk9mz9c"}],"components":[{"status":"operational","name":"Data Collection API","created_at":"2013-07-23T18:44:56.207Z","updated_at":"2015-02-19T04:34:26.123Z","position":1,"description":null,"group_id":null,"id":"19fvy2vdltdq","page_id":"z3mvdbpvy7yh"}]}]}

module.exports = ->
  nock('http://status.keen.io:80')
    .get('/?format=json')
    .reply(200, response, { 'access-control-allow-origin': '*',
    'access-control-request-method': '*',
    'cache-control': 'max-age=0, private, must-revalidate',
    'content-type': 'application/json; charset=utf-8',
    date: 'Thu, 19 Feb 2015 21:44:27 GMT',
    etag: '"e68b42111462421b9fc7c0de60752659"',
    status: '200 OK',
    vary: 'Accept-Encoding',
    'x-content-type-options': 'nosniff',
    'x-rack-cache': 'miss',
    'x-request-id': '2012275f-9835-47fe-8350-51d71868c9fc',
    'x-runtime': '0.016886',
    'x-statuspage-skip-logging': 'true',
    'x-statuspage-version': '9577b483d85e06d1848bc6995657efd2a03072ea',
    'x-xss-protection': '1; mode=block',
    'transfer-encoding': 'chunked',
    connection: 'keep-alive' })