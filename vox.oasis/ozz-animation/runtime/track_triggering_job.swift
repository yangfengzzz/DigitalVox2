//
//  track_triggering_job.swift
//  vox.oasis
//
//  Created by 杨丰 on 2021/11/1.
//

import Foundation

// Track edge triggering job implementation. Edge triggering wording refers to
// signal processing, where a signal edge is a transition from low to high or
// from high to low. It is called an "edge" because of the square wave which
// represents a signal has edges at those points. A rising edge is the
// transition from low to high, a falling edge is from high to low.
// TrackTriggeringJob detects when track curve crosses a threshold value,
// triggering dated events that can be processed as state changes.
// Only FloatTrack is supported, because comparing to a threshold for other
// track types isn't possible.
// The job execution actually performs a lazy evaluation of edges. It builds an
// iterator that will process the next edge on each call to ++ operator.
struct TrackTriggeringJob {
    // Validates job parameters.
    func Validate() -> Bool {
        fatalError()
    }

    // Validates and executes job. Execution is lazy. Iterator operator ++ is
    // actually doing the processing work.
    func Run() -> Bool {
        fatalError()
    }

    // Input range. 0 is the beginning of the track, 1 is the end.
    // from and to can be of any sign, any order, and any range. The job will
    // perform accordingly:
    // - if difference between from and to is greater than 1, the iterator will
    // loop multiple times on the track.
    // - if from is greater than to, then the track is processed backward (rising
    // edges in forward become falling ones).
    var from: Float
    var to: Float

    // Edge detection threshold value.
    // A rising edge is detected as soon as the track value becomes greater than
    // the threshold.
    // A falling edge is detected as soon as the track value becomes smaller or
    // equal than the threshold.
    var threshold: Float

    // Track to sample.
    var track: FloatTrack

    // Structure of an edge as detected by the job.
    struct Edge {
        var ratio: Float  // Ratio at which track value crossed threshold.
        var rising: Bool  // true is edge is rising (getting higher than threshold).
    }
}
