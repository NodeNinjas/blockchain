// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ExcellenceBadge.sol";
import "./ExperienceBadge.sol";
import "./LoyaltyBadge.sol";
import "./TrustWorthyBadge.sol";

contract FreelancePlatform {
    enum JobStatus { Open, InProgress, Completed, Reviewed }
    
    struct Job {
        address client;
        address freelancer;
        uint256 budget;
        JobStatus status;
    }
    
    struct Review {
        uint8 rating;  // Rating out of 10
        bool isSatisfied;
    }
    
    uint256 public jobCounter = 0;
    mapping(uint256 => Job) public jobs;
    mapping(uint256 => Review) public reviews;
    
    mapping(address => uint256) public freelancerJobCount;
    mapping(address => uint256) public clientJobCount;
    mapping(address => uint256) public freelancerReviewSum;
    mapping(address => uint256) public clientReviewSum;

    ExperienceBadge public experienceBadge;
    ExcellenceBadge public excellenceBadge;
    LoyaltyBadge public loyaltyBadge;
    TrustworthyBadge public trustworthyBadge;

    address public platform;
    
    constructor(
        address _experienceBadge,
        address _excellenceBadge,
        address _loyaltyBadge,
        address _trustworthyBadge
    ) {
        experienceBadge = ExperienceBadge(_experienceBadge);
        excellenceBadge = ExcellenceBadge(_excellenceBadge);
        loyaltyBadge = LoyaltyBadge(_loyaltyBadge);
        trustworthyBadge = TrustworthyBadge(_trustworthyBadge);

        platform = msg.sender;
    }
    
    function postJob(uint256 _budget) public returns (uint256) {
        jobCounter++;
        jobs[jobCounter] = Job({
            client: msg.sender,
            freelancer: address(0),
            budget: _budget,
            status: JobStatus.Open
        });
        clientJobCount[msg.sender]++;
        return jobCounter;
    }
    
    function applyForJob(uint256 _jobId) public {
        Job storage job = jobs[_jobId];
        require(job.status == JobStatus.Open, "Job is not open");
        job.freelancer = msg.sender;
        job.status = JobStatus.InProgress;
    }
    
    function markJobCompleted(uint256 _jobId) public {
        Job storage job = jobs[_jobId];
        require(msg.sender == job.freelancer, "Not the freelancer for this job");
        require(job.status == JobStatus.InProgress, "Job is not in progress");
        job.status = JobStatus.Completed;
    }
    
    function reviewJob(uint256 _jobId, uint8 _rating, bool _isSatisfied) public payable {
        Job storage job = jobs[_jobId];
        require(msg.sender == job.client, "Not the client for this job");
        require(job.status == JobStatus.Completed, "Job is not completed");
        job.status = JobStatus.Reviewed;
        reviews[_jobId] = Review({
            rating: _rating,
            isSatisfied: _isSatisfied
        });
        freelancerReviewSum[job.freelancer] += _rating;
        clientReviewSum[job.client] += _rating;
        if (_isSatisfied) {
            payable(job.freelancer).transfer(job.budget);
        } else {
            uint256 refund = (job.budget * 80) / 100;
            uint256 freelancerPayment = (job.budget * 10) / 100;
            payable(job.client).transfer(refund);
            payable(job.freelancer).transfer(freelancerPayment);
            // Remaining 10% stays with the contract (platform fee)
        }
    }
    
    function checkAndAwardBadges(address freelancer, address client) public {
        require(msg.sender == platform, "only Platform can award badges");

        // Freelancer Badges
        if (freelancerJobCount[freelancer] >= 2) {
            experienceBadge.mint(freelancer);
        }

        if (
            (freelancerJobCount[freelancer] > 0) && 
            (freelancerReviewSum[freelancer] / freelancerJobCount[freelancer] > 8)
        ) {
            excellenceBadge.mint(freelancer);
        }

        // Client Badges
        if (clientJobCount[client] >= 2) {
            loyaltyBadge.mint(client);
        }

        if (
            (clientJobCount[client] > 0) && 
            (clientReviewSum[client] / clientJobCount[client] > 8)
        ) {
            trustworthyBadge.mint(client);
        }
    }
}
